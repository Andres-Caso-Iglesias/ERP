import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Security headers
  app.use(helmet());

  // CORS - restrictive by default
  app.enableCors({
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
    credentials: true,
  });

  // Global validation pipe - sanitizes and validates all inputs
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,           // strips properties not in DTO
      forbidNonWhitelisted: true, // throws error for unknown properties
      transform: true,           // auto-transforms payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true, // auto-convert types
      },
    }),
  );

  // Global prefix
  app.setGlobalPrefix('api');

  const port = process.env.PORT || 5000;
  await app.listen(port);
  console.log(`🚀 Server running on port ${port}`);
}
bootstrap();
