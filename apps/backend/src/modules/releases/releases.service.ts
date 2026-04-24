import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class ReleasesService {
  constructor(private prisma: PrismaService) {}

  async getLatestRelease() {
    // For now we assume a single latest release config or we order by latest buildNumber
    const latest = await this.prisma.appRelease.findFirst({
      orderBy: {
        buildNumber: 'desc',
      },
    });

    if (!latest) {
      // Return a safe default if no config exists in db
      return {
        latest_version: '1.0.0',
        build_number: 1,
        force_update: false,
        apk_url: '',
        message: 'Welcome to Indo Pay',
        release_notes: '',
      };
    }

    return {
      latest_version: latest.latestVersion,
      build_number: latest.buildNumber,
      force_update: latest.forceUpdate,
      apk_url: latest.apkUrl,
      message: latest.message,
      release_notes: latest.releaseNotes,
    };
  }
}
