import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateEntryDto } from './dto/create-entry.dto';
import { UpdateEntryDto } from './dto/update-entry.dto';

@Injectable()
export class AccountingService {
  constructor(private readonly database: DatabaseService) {}

  async findAll() {
    const sql = this.database.getSql();
    return sql`SELECT * FROM accounting ORDER BY transaction_date DESC`;
  }

  async findOne(id: number) {
    const sql = this.database.getSql();
    const [entry] = await sql`SELECT * FROM accounting WHERE id = ${id}`;
    if (!entry) {
      throw new NotFoundException(`Accounting entry with ID ${id} not found`);
    }
    return entry;
  }

  async create(dto: CreateEntryDto) {
    const sql = this.database.getSql();
    const [entry] = await sql`
      INSERT INTO accounting (transaction_date, description, amount, type, category)
      VALUES (${dto.transactionDate}, ${dto.description}, ${dto.amount}, ${dto.type}, ${dto.category || 'general'})
      RETURNING *
    `;
    return entry;
  }

  async update(id: number, dto: UpdateEntryDto) {
    const sql = this.database.getSql();
    const [entry] = await sql`
      UPDATE accounting
      SET transaction_date = COALESCE(${dto.transactionDate}, transaction_date),
          description = COALESCE(${dto.description}, description),
          amount = COALESCE(${dto.amount}, amount),
          type = COALESCE(${dto.type}, type),
          category = COALESCE(${dto.category}, category)
      WHERE id = ${id}
      RETURNING *
    `;
    if (!entry) {
      throw new NotFoundException(`Accounting entry with ID ${id} not found`);
    }
    return entry;
  }

  async remove(id: number) {
    const sql = this.database.getSql();
    const [entry] = await sql`DELETE FROM accounting WHERE id = ${id} RETURNING *`;
    if (!entry) {
      throw new NotFoundException(`Accounting entry with ID ${id} not found`);
    }
    return { msg: 'Accounting entry deleted successfully' };
  }
}
