import { Injectable } from "@nestjs/common";

import { PrismaService } from "../../common/prisma/prisma.service";

@Injectable()
export class StatementExportService {
  constructor(private readonly prisma: PrismaService) {}

  async createExport(input: {
    userId: string;
    fromDate: string;
    toDate: string;
    format: "PDF" | "CSV";
  }) {
    return this.prisma.statementExport.create({
      data: {
        userId: input.userId,
        fromDate: new Date(input.fromDate),
        toDate: new Date(input.toDate),
        fileUrl: `https://files.indo-pay.local/statements/${input.userId}-${Date.now()}.${
          input.format === "CSV" ? "csv" : "pdf"
        }`
      }
    });
  }
}
