import { Test, TestingModule } from '@nestjs/testing';
import { NotificationsService } from './notifications.service';
import { DatabaseService } from '../database/database.service';
import { NotFoundException } from '@nestjs/common';

describe('NotificationsService', () => {
  let service: NotificationsService;
  let mockDatabase: { getSql: jest.Mock };

  beforeEach(async () => {
    mockDatabase = { getSql: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationsService,
        { provide: DatabaseService, useValue: mockDatabase },
      ],
    }).compile();

    service = module.get<NotificationsService>(NotificationsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAllByUser', () => {
    it('should return notifications for a user', async () => {
      const mockNotifications = [{ id: 1, message: 'Test' }];
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue(mockNotifications));

      const result = await service.findAllByUser(1);
      expect(result).toEqual(mockNotifications);
    });
  });

  describe('create', () => {
    it('should create a notification', async () => {
      const mockNotification = { id: 1, user_id: 1, message: 'Test', status: 'unread' };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockNotification]));

      const result = await service.create({ userId: 1, message: 'Test' });
      expect(result).toEqual(mockNotification);
    });
  });

  describe('markAsRead', () => {
    it('should mark notification as read', async () => {
      const mockNotification = { id: 1, status: 'read' };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockNotification]));

      const result = await service.markAsRead(1, 1);
      expect(result.status).toBe('read');
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.markAsRead(999, 1)).rejects.toThrow(NotFoundException);
    });
  });

  describe('remove', () => {
    it('should delete a notification', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([{ id: 1 }]));

      const result = await service.remove(1, 1);
      expect(result.msg).toBe('Notification deleted successfully');
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.remove(999, 1)).rejects.toThrow(NotFoundException);
    });
  });
});
