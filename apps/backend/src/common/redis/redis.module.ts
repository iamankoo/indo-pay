import { Global, Module } from "@nestjs/common";

import { RedisService } from "./redis.service";
import { WalletLockService } from "./wallet-lock.service";

@Global()
@Module({
  providers: [RedisService, WalletLockService],
  exports: [RedisService, WalletLockService]
})
export class RedisModule {}
