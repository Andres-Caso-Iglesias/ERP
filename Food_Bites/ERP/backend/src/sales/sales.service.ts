import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateSaleDto } from './dto/create-sale.dto';
import { UpdateSaleDto } from './dto/update-sale.dto';

@Injectable()
export class SalesService {
  constructor(private readonly database: DatabaseService) {}

  async findAll() {
    const sql = this.database.getSql();
    return sql`SELECT * FROM sales ORDER BY sale_date DESC`;
  }

  async findOne(id: number) {
    const sql = this.database.getSql();
    const [sale] = await sql`SELECT * FROM sales WHERE id = ${id}`;
    if (!sale) {
      throw new NotFoundException(`Sale with ID ${id} not found`);
    }
    return sale;
  }

  async create(dto: CreateSaleDto) {
    const sql = this.database.getSql();
    const [sale] = await sql`
      INSERT INTO sales (client_id, sale_date, total, status)
      VALUES (${dto.clientId}, ${dto.saleDate}, ${dto.total}, ${dto.status || 'pending'})
      RETURNING *
    `;
    return sale;
  }

  async update(id: number, dto: UpdateSaleDto) {
    const sql = this.database.getSql();
    const [sale] = await sql`
      UPDATE sales
      SET client_id = COALESCE(${dto.clientId}, client_id),
          sale_date = COALESCE(${dto.saleDate}, sale_date),
          total = COALESCE(${dto.total}, total),
          status = COALESCE(${dto.status}, status)
      WHERE id = ${id}
      RETURNING *
    `;
    if (!sale) {
      throw new NotFoundException(`Sale with ID ${id} not found`);
    }
    return sale;
  }

  async remove(id: number) {
    const sql = this.database.getSql();
    const [sale] = await sql`DELETE FROM sales WHERE id = ${id} RETURNING *`;
    if (!sale) {
      throw new NotFoundException(`Sale with ID ${id} not found`);
    }
    return { msg: 'Sale deleted successfully' };
  }
}
