import { Controller, Get } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";

@ApiTags("health")
@Controller("health")
export class HealthController {
  @Get()
  @ApiOperation({ summary: "Backend health check" })
  getHealth() {
    return {
      status: "ok",
      service: "indo-pay-backend",
      timestamp: new Date().toISOString()
    };
  }
}
