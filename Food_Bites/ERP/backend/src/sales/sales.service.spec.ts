import { Test, TestingModule } from '@nestjs/testing';
import { SalesService } from './sales.service';
import { DatabaseService } from '../database/database.service';
import { NotFoundException } from '@nestjs/common';

describe('SalesService', () => {
  let service: SalesService;
  let mockDatabase: { getSql: jest.Mock };

  beforeEach(async () => {
    mockDatabase = { getSql: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SalesService,
        { provide: DatabaseService, useValue: mockDatabase },
      ],
    }).compile();

    service = module.get<SalesService>(SalesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all sales', async () => {
      const mockSales = [{ id: 1, total: 100 }, { id: 2, total: 200 }];
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue(mockSales));

      const result = await service.findAll();
      expect(result).toEqual(mockSales);
    });
  });

  describe('findOne', () => {
    it('should return a sale by id', async () => {
      const mockSale = { id: 1, total: 100 };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockSale]));

      const result = await service.findOne(1);
      expect(result).toEqual(mockSale);
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.findOne(999)).rejects.toThrow(NotFoundException);
    });
  });

  describe('create', () => {
    it('should create a new sale', async () => {
      const mockSale = { id: 1, client_id: 1, total: 50, status: 'pending' };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockSale]));

      const result = await service.create({
        clientId: 1,
        saleDate: '2025-01-01T00:00:00Z',
        total: 50,
      });

      expect(result).toEqual(mockSale);
    });
  });

  describe('remove', () => {
    it('should delete a sale', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([{ id: 1 }]));

      const result = await service.remove(1);
      expect(result.msg).toBe('Sale deleted successfully');
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.remove(999)).rejects.toThrow(NotFoundException);
    });
  });
});
