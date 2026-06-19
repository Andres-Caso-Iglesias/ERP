import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import postgres from 'postgres';

@Injectable()
export class DatabaseService implements OnModuleInit, OnModuleDestroy {
  private sql: postgres.Sql;

  async onModuleInit() {
    const connectionString = process.env.DATABASE_URL;
    if (!connectionString) {
      throw new Error('DATABASE_URL environment variable is not set');
    }

    this.sql = postgres(connectionString, {
      max: 10,                    // connection pool size
      idle_timeout: 20,           // close idle connections after 20s
      connect_timeout: 10,        // connection timeout
      ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
    });

    // Test connection
    try {
      await this.sql`SELECT 1`;
      console.log('✅ Database connection successful');
    } catch (error) {
      console.error('❌ Database connection failed:', error);
      throw error;
    }
  }

  async onModuleDestroy() {
    await this.sql.end();
  }

  getSql(): postgres.Sql<{}> {
    return this.sql;
  }
}
