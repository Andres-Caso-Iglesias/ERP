import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';

@Injectable()
export class InventoryService {
  constructor(private readonly database: DatabaseService) {}

  async findAll() {
    const sql = this.database.getSql();
    return sql`SELECT * FROM inventory ORDER BY product_name`;
  }

  async findOne(id: number) {
    const sql = this.database.getSql();
    const [product] = await sql`SELECT * FROM inventory WHERE id = ${id}`;
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    return product;
  }

  async create(dto: CreateProductDto) {
    const sql = this.database.getSql();
    const [product] = await sql`
      INSERT INTO inventory (product_name, quantity, price, category)
      VALUES (${dto.productName}, ${dto.quantity}, ${dto.price}, ${dto.category})
      RETURNING *
    `;
    return product;
  }

  async update(id: number, dto: UpdateProductDto) {
    const sql = this.database.getSql();
    const [product] = await sql`
      UPDATE inventory
      SET product_name = COALESCE(${dto.productName}, product_name),
          quantity = COALESCE(${dto.quantity}, quantity),
          price = COALESCE(${dto.price}, price),
          category = COALESCE(${dto.category}, category)
      WHERE id = ${id}
      RETURNING *
    `;
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    return product;
  }

  async remove(id: number) {
    const sql = this.database.getSql();
    const [product] = await sql`DELETE FROM inventory WHERE id = ${id} RETURNING *`;
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    return { msg: 'Product deleted successfully' };
  }
}
