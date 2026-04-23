import { Injectable } from "@nestjs/common";

@Injectable()
export class NotificationsService {
  rewardCredited(userId: string, amount: number) {
    return {
      userId,
      type: "REWARD_CREDITED",
      title: "Cashback added",
      message: `INR ${amount} has been added to your promo wallet.`
    };
  }

  expiryReminder(userId: string, amount: number, daysRemaining: number) {
    return {
      userId,
      type: "WALLET_EXPIRY_REMINDER",
      title: "Rewards expiring soon",
      message: `INR ${amount} expires in ${daysRemaining} days.`
    };
  }
}

