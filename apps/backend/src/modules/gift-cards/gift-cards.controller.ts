import { Body, Controller, Get, Post } from "@nestjs/common";

import { GiftCardsService } from "./gift-cards.service";

@Controller("gift-cards")
export class GiftCardsController {
  constructor(private readonly giftCardsService: GiftCardsService) {}

  @Get("catalog")
  getCatalog() {
    return this.giftCardsService.getCatalog();
  }

  @Post("purchase")
  purchase(
    @Body()
    body: {
      userId: string;
      brandCode: string;
      amount: number;
      walletBalance: number;
    }
  ) {
    return this.giftCardsService.purchase(body);
  }
}

