import {
  UnprocessableEntityException,
  ValidationError,
  ValidationPipe
} from "@nestjs/common";
import { NestFactory } from "@nestjs/core";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";

import { AppModule } from "./app.module";
import { ApiErrorFilter } from "./common/http/api-error.filter";

function flattenValidationErrors(
  errors: ValidationError[]
): Array<{ field: string; message: string }> {
  return errors.flatMap((error) => {
    const currentErrors = Object.values(error.constraints ?? {}).map((message) => ({
      field: error.property,
      message
    }));

    if (!error.children?.length) {
      return currentErrors;
    }

    return [
      ...currentErrors,
      ...flattenValidationErrors(error.children).map((child: {
        field: string;
        message: string;
      }) => ({
        ...child,
        field: `${error.property}.${child.field}`
      }))
    ];
  });
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    rawBody: true
  });

  app.enableCors();
  app.setGlobalPrefix("api/v1");
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      exceptionFactory: (errors) =>
        new UnprocessableEntityException({
          code: "VALIDATION_FAILED",
          message: "Request validation failed",
          details: flattenValidationErrors(errors)
        })
    })
  );
  app.useGlobalFilters(new ApiErrorFilter());
  app.enableShutdownHooks();

  const config = new DocumentBuilder()
    .setTitle("Indo Pay API")
    .setDescription(
      "Payments, wallet, rewards, passbook, merchant, bank transfer, and admin analytics APIs"
    )
    .setVersion("1.0")
    .addBearerAuth()
    .addApiKey(
      {
        type: "apiKey",
        name: "x-idempotency-key",
        in: "header"
      },
      "idempotency"
    )
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("api", app, document);

  await app.listen(process.env.PORT ? Number(process.env.PORT) : 4000, "0.0.0.0");
}

void bootstrap();
