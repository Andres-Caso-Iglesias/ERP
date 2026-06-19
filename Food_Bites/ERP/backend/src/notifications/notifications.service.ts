import { Injectable, NotFoundException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { CreateNotificationDto } from './dto/create-notification.dto';

@Injectable()
export class NotificationsService {
  constructor(private readonly database: DatabaseService) {}

  async findAllByUser(userId: number) {
    const sql = this.database.getSql();
    return sql`
      SELECT * FROM notifications
      WHERE user_id = ${userId}
      ORDER BY created_at DESC
    `;
  }

  async findOne(id: number, userId: number) {
    const sql = this.database.getSql();
    const [notification] = await sql`
      SELECT * FROM notifications
      WHERE id = ${id} AND user_id = ${userId}
    `;
    if (!notification) {
      throw new NotFoundException(`Notification with ID ${id} not found`);
    }
    return notification;
  }

  async create(dto: CreateNotificationDto) {
    const sql = this.database.getSql();
    const [notification] = await sql`
      INSERT INTO notifications (user_id, message, status)
      VALUES (${dto.userId}, ${dto.message}, 'unread')
      RETURNING *
    `;
    return notification;
  }

  async markAsRead(id: number, userId: number) {
    const sql = this.database.getSql();
    const [notification] = await sql`
      UPDATE notifications
      SET status = 'read'
      WHERE id = ${id} AND user_id = ${userId}
      RETURNING *
    `;
    if (!notification) {
      throw new NotFoundException(`Notification with ID ${id} not found`);
    }
    return notification;
  }

  async remove(id: number, userId: number) {
    const sql = this.database.getSql();
    const [notification] = await sql`
      DELETE FROM notifications
      WHERE id = ${id} AND user_id = ${userId}
      RETURNING *
    `;
    if (!notification) {
      throw new NotFoundException(`Notification with ID ${id} not found`);
    }
    return { msg: 'Notification deleted successfully' };
  }
}
