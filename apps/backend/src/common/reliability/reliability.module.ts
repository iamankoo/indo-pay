import { Module } from "@nestjs/common";

import { NotificationsModule } from "../../modules/notifications/notifications.module";
import { DeadLetterQueueService } from "./dead-letter-queue.service";
import { IdempotencyService } from "./idempotency.service";
import { NotificationDispatchService } from "./notification-dispatch.service";
import { RiskQueueService } from "./risk-queue.service";
import { WebhookSecurityService } from "./webhook-security.service";

@Module({
  imports: [NotificationsModule],
  providers: [
    IdempotencyService,
    RiskQueueService,
    NotificationDispatchService,
    DeadLetterQueueService,
    WebhookSecurityService
  ],
  exports: [
    IdempotencyService,
    RiskQueueService,
    NotificationDispatchService,
    DeadLetterQueueService,
    WebhookSecurityService
  ]
})
export class ReliabilityModule {}
