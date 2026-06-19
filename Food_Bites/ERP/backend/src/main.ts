import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { DatabaseBootstrap } from './database/database-bootstrap';

async function bootstrap() {
  const logger = new Logger('Bootstrap');

  // ============================================================
  // STEP 1: PostgreSQL Auto-Setup
  // ============================================================
  // Check if PostgreSQL is running, create DB if needed, run migrations
  logger.log('🔍 Checking PostgreSQL setup...');
  
  const dbBootstrap = new DatabaseBootstrap();
  try {
    await dbBootstrap.init();
    logger.log('✅ PostgreSQL ready');
  } catch (error) {
    logger.error('❌ PostgreSQL setup failed');
    logger.error('   Make sure PostgreSQL is installed and running.');
    logger.error(`   Connection: ${process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/erp_food_bites'}`);
    logger.error(`   Error: ${error.message}`);
    process.exit(1);
  }

  // ============================================================
  // STEP 2: Start NestJS Application
  // ============================================================
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
  logger.log(`🚀 Server running on port ${port}`);
  logger.log(`📍 API: http://localhost:${port}/api`);
}
bootstrap();
