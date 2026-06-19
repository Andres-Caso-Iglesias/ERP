import { Test, TestingModule } from '@nestjs/testing';
import { AccountingService } from './accounting.service';
import { DatabaseService } from '../database/database.service';
import { NotFoundException } from '@nestjs/common';

describe('AccountingService', () => {
  let service: AccountingService;
  let mockDatabase: { getSql: jest.Mock };

  beforeEach(async () => {
    mockDatabase = { getSql: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AccountingService,
        { provide: DatabaseService, useValue: mockDatabase },
      ],
    }).compile();

    service = module.get<AccountingService>(AccountingService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all entries', async () => {
      const mockEntries = [{ id: 1, amount: 100 }];
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue(mockEntries));

      const result = await service.findAll();
      expect(result).toEqual(mockEntries);
    });
  });

  describe('findOne', () => {
    it('should return an entry by id', async () => {
      const mockEntry = { id: 1, amount: 100 };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockEntry]));

      const result = await service.findOne(1);
      expect(result).toEqual(mockEntry);
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.findOne(999)).rejects.toThrow(NotFoundException);
    });
  });

  describe('create', () => {
    it('should create a new entry', async () => {
      const mockEntry = { id: 1, amount: 150, type: 'income' };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockEntry]));

      const result = await service.create({
        transactionDate: '2025-01-01T00:00:00Z',
        description: 'Venta',
        amount: 150,
        type: 'income',
      });

      expect(result).toEqual(mockEntry);
    });
  });

  describe('remove', () => {
    it('should delete an entry', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([{ id: 1 }]));

      const result = await service.remove(1);
      expect(result.msg).toBe('Accounting entry deleted successfully');
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.remove(999)).rejects.toThrow(NotFoundException);
    });
  });
});
