import { Controller, Get } from '@nestjs/common';
import { ReleasesService } from './releases.service';

@Controller('releases')
export class ReleasesController {
  constructor(private readonly releasesService: ReleasesService) {}

  @Get('latest')
  async getLatestRelease() {
    return this.releasesService.getLatestRelease();
  }
}
