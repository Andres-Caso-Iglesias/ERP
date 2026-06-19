import { Injectable, Logger } from '@nestjs/common';
import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class DatabaseBootstrap {
  private readonly logger = new Logger(DatabaseBootstrap.name);
  private readonly pgHost: string;
  private readonly pgPort: number;
  private readonly pgUser: string;
  private readonly dbName: string;

  constructor() {
    // Parse DATABASE_URL or use defaults
    const dbUrl = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/erp_food_bites';
    const url = new URL(dbUrl);
    
    this.pgHost = url.hostname || 'localhost';
    this.pgPort = parseInt(url.port || '5432', 10);
    this.pgUser = url.username || 'postgres';
    this.dbName = url.pathname.replace('/', '') || 'erp_food_bites';
  }

  /**
   * Main entry point — runs all setup steps
   */
  async init(): Promise<void> {
    this.logger.log('🔍 Checking PostgreSQL setup...');

    // Step 1: Check if PostgreSQL is reachable
    if (!this.isPostgresRunning()) {
      this.logger.error('❌ PostgreSQL is not running or not accessible');
      this.logger.error(`   Expected at: ${this.pgHost}:${this.pgPort}`);
      this.logger.error('   Please install and start PostgreSQL, then restart the server.');
      throw new Error('PostgreSQL is not available');
    }
    this.logger.log('✅ PostgreSQL is running');

    // Step 2: Check if database exists
    if (!this.databaseExists()) {
      this.logger.log(`📦 Creating database "${this.dbName}"...`);
      this.createDatabase();
      this.logger.log(`✅ Database "${this.dbName}" created`);
    } else {
      this.logger.log(`✅ Database "${this.dbName}" already exists`);
    }

    // Step 3: Run migrations
    this.logger.log('🔄 Running migrations...');
    this.runMigrations();
    this.logger.log('✅ Migrations completed');
  }

  /**
   * Check if PostgreSQL server is running
   */
  private isPostgresRunning(): boolean {
    try {
      const result = this.execPsql(
        'SELECT 1',
        { throwOnError: false }
      );
      return result.success;
    } catch {
      return false;
    }
  }

  /**
   * Check if the target database exists
   */
  private databaseExists(): boolean {
    try {
      const result = this.execPsql(
        `SELECT 1 FROM pg_database WHERE datname = '${this.dbName}'`,
        { throwOnError: false, useDatabase: false }
      );
      return result.success && result.stdout.includes('1');
    } catch {
      return false;
    }
  }

  /**
   * Create the target database
   */
  private createDatabase(): void {
    this.execPsql(
      `CREATE DATABASE "${this.dbName}"`,
      { useDatabase: false }
    );
  }

  /**
   * Run all SQL migration files
   */
  private runMigrations(): void {
    const migrationsDir = path.join(__dirname, 'migrations');
    
    // Create migrations directory if it doesn't exist
    if (!fs.existsSync(migrationsDir)) {
      fs.mkdirSync(migrationsDir, { recursive: true });
      this.logger.log('   Created migrations directory');
      return;
    }

    const files = fs.readdirSync(migrationsDir)
      .filter(f => f.endsWith('.sql'))
      .sort();

    if (files.length === 0) {
      this.logger.log('   No migration files found');
      return;
    }

    for (const file of files) {
      const filePath = path.join(migrationsDir, file);
      const sql = fs.readFileSync(filePath, 'utf8');
      
      try {
        this.execPsql(sql, { stdin: true });
        this.logger.log(`   ✅ ${file}`);
      } catch (error) {
        this.logger.error(`   ❌ ${file}: ${error.message}`);
        throw error;
      }
    }
  }

  /**
   * Execute a psql command
   */
  private execPsql(
    command: string,
    options: {
      throwOnError?: boolean;
      useDatabase?: boolean;
      stdin?: boolean;
    } = {}
  ): { success: boolean; stdout: string; stderr: string } {
    const { throwOnError = true, useDatabase = true, stdin = false } = options;
    
    const dbFlag = useDatabase ? `-d ${this.dbName}` : '';
    const hostFlag = `-h ${this.pgHost}`;
    const portFlag = `-p ${this.pgPort}`;
    const userFlag = `-U ${this.pgUser}`;
    
    const fullCommand = `psql ${hostFlag} ${portFlag} ${userFlag} ${dbFlag} -t -A -c "${command.replace(/"/g, '\\"')}"`;
    
    try {
      const stdout = execSync(fullCommand, {
        encoding: 'utf8',
        timeout: 10000,
        stdio: stdin ? ['pipe', 'pipe', 'pipe'] : undefined,
      });
      return { success: true, stdout: stdout.trim(), stderr: '' };
    } catch (error) {
      if (throwOnError) {
        throw error;
      }
      return {
        success: false,
        stdout: error.stdout || '',
        stderr: error.stderr || error.message,
      };
    }
  }
}
