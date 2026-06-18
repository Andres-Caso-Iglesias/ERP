import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateClientDto } from './dto/create-client.dto';
import { UpdateClientDto } from './dto/update-client.dto';

@Injectable()
export class ClientsService {
  constructor(private readonly database: DatabaseService) {}

  async findAll() {
    const sql = this.database.getSql();
    return sql`SELECT * FROM clients ORDER BY name`;
  }

  async findOne(id: number) {
    const sql = this.database.getSql();
    const [client] = await sql`SELECT * FROM clients WHERE id = ${id}`;
    if (!client) {
      throw new NotFoundException(`Client with ID ${id} not found`);
    }
    return client;
  }

  async create(dto: CreateClientDto) {
    const sql = this.database.getSql();
    const [client] = await sql`
      INSERT INTO clients (name, email, phone, status)
      VALUES (${dto.name}, ${dto.email}, ${dto.phone}, ${dto.status})
      RETURNING *
    `;
    return client;
  }

  async update(id: number, dto: UpdateClientDto) {
    const sql = this.database.getSql();
    const [client] = await sql`
      UPDATE clients
      SET name = COALESCE(${dto.name}, name),
          email = COALESCE(${dto.email}, email),
          phone = COALESCE(${dto.phone}, phone),
          status = COALESCE(${dto.status}, status)
      WHERE id = ${id}
      RETURNING *
    `;
    if (!client) {
      throw new NotFoundException(`Client with ID ${id} not found`);
    }
    return client;
  }

  async remove(id: number) {
    const sql = this.database.getSql();
    const [client] = await sql`DELETE FROM clients WHERE id = ${id} RETURNING *`;
    if (!client) {
      throw new NotFoundException(`Client with ID ${id} not found`);
    }
    return { msg: 'Client deleted successfully' };
  }
}
