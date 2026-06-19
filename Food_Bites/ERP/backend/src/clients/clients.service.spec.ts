import { Test, TestingModule } from '@nestjs/testing';
import { ClientsService } from './clients.service';
import { DatabaseService } from '../database/database.service';
import { NotFoundException } from '@nestjs/common';

describe('ClientsService', () => {
  let service: ClientsService;
  let mockDatabase: { getSql: jest.Mock };

  beforeEach(async () => {
    mockDatabase = { getSql: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ClientsService,
        { provide: DatabaseService, useValue: mockDatabase },
      ],
    }).compile();

    service = module.get<ClientsService>(ClientsService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all clients', async () => {
      const mockClients = [{ id: 1, name: 'Juan' }];
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue(mockClients));

      const result = await service.findAll();
      expect(result).toEqual(mockClients);
    });
  });

  describe('findOne', () => {
    it('should return a client by id', async () => {
      const mockClient = { id: 1, name: 'Juan' };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockClient]));

      const result = await service.findOne(1);
      expect(result).toEqual(mockClient);
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.findOne(999)).rejects.toThrow(NotFoundException);
    });
  });

  describe('create', () => {
    it('should create a new client', async () => {
      const mockClient = { id: 1, name: 'Juan', email: 'juan@test.com' };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockClient]));

      const result = await service.create({ name: 'Juan', email: 'juan@test.com' });
      expect(result).toEqual(mockClient);
    });
  });

  describe('remove', () => {
    it('should delete a client', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([{ id: 1 }]));

      const result = await service.remove(1);
      expect(result.msg).toBe('Client deleted successfully');
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.remove(999)).rejects.toThrow(NotFoundException);
    });
  });
});
