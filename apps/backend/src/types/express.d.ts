declare module "express" {
  export interface Request {
    body: unknown;
    header(name: string): string | undefined;
    headers: Record<string, string | string[] | undefined>;
    ip: string;
    method: string;
    originalUrl: string;
    url: string;
    rawBody?: Buffer;
  }

  export interface Response {
    status(code: number): Response;
    json(body: unknown): Response;
    setHeader(name: string, value: string): void;
  }

  export type NextFunction = () => void;
}
