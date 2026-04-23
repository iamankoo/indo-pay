import { Injectable, Logger, OnModuleDestroy } from "@nestjs/common";
import Redis from "ioredis";

@Injectable()
export class RedisService implements OnModuleDestroy {
  private readonly logger = new Logger(RedisService.name);

  private client: Redis | null = null;

  private connectionAttempted = false;

  private fallbackAlerted = false;

  private get redisUrl() {
    return process.env.REDIS_URL ?? "redis://127.0.0.1:6379";
  }

  async onModuleDestroy() {
    if (this.client) {
      await this.client.quit();
    }
  }

  async getClient() {
    if (this.client) {
      return this.client;
    }

    if (this.connectionAttempted) {
      return null;
    }

    this.connectionAttempted = true;

    try {
      const client = new Redis(this.redisUrl, {
        maxRetriesPerRequest: 1,
        lazyConnect: true,
        enableOfflineQueue: false
      });

      client.on("error", (error) => {
        this.logger.warn(`Redis error: ${error.message}`);
      });

      await client.connect();
      this.client = client;
      this.logger.log(`Redis connected at ${this.redisUrl}`);

      return this.client;
    } catch (error) {
      this.raiseFallbackAlert(
        `Redis unavailable, entering degraded mode: ${
          error instanceof Error ? error.message : "unknown error"
        }`
      );

      return null;
    }
  }

  async get(key: string) {
    const client = await this.getClient();
    return client ? client.get(key) : null;
  }

  async set(
    key: string,
    value: string,
    ttlSeconds?: number,
    mode?: "NX" | "XX"
  ) {
    const client = await this.getClient();
    if (!client) {
      return null;
    }

    const command = ["SET", key, value];

    if (ttlSeconds) {
      command.push("EX", String(ttlSeconds));
    }

    if (mode) {
      command.push(mode);
    }

    const result = await client.call(...(command as [string, ...string[]]));
    return result ? String(result) : null;
  }

  async del(key: string) {
    const client = await this.getClient();
    if (!client) {
      return 0;
    }

    return client.del(key);
  }

  async incr(key: string, ttlSeconds: number) {
    const client = await this.getClient();
    if (!client) {
      return null;
    }

    const value = await client.incr(key);
    if (value === 1) {
      await client.expire(key, ttlSeconds);
    }

    return value;
  }

  async lpush(key: string, value: string) {
    const client = await this.getClient();
    if (!client) {
      return null;
    }

    return client.lpush(key, value);
  }

  async eval(script: string, numberOfKeys: number, ...args: string[]) {
    const client = await this.getClient();
    if (!client) {
      return null;
    }

    return client.eval(script, numberOfKeys, ...args);
  }

  async setJson<T>(
    key: string,
    value: T,
    ttlSeconds?: number,
    mode?: "NX" | "XX"
  ) {
    return this.set(key, JSON.stringify(value), ttlSeconds, mode);
  }

  async getJson<T>(key: string) {
    const rawValue = await this.get(key);
    if (!rawValue) {
      return null;
    }

    return JSON.parse(rawValue) as T;
  }

  raiseFallbackAlert(message: string) {
    if (this.fallbackAlerted) {
      return;
    }

    this.fallbackAlerted = true;
    this.logger.error(message);
  }
}
