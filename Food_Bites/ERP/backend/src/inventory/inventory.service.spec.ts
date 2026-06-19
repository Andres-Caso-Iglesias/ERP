import { Test, TestingModule } from '@nestjs/testing';
import { InventoryService } from './inventory.service';
import { DatabaseService } from '../database/database.service';
import { NotFoundException } from '@nestjs/common';

describe('InventoryService', () => {
  let service: InventoryService;
  let mockDatabase: { getSql: jest.Mock };

  beforeEach(async () => {
    mockDatabase = { getSql: jest.fn() };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InventoryService,
        { provide: DatabaseService, useValue: mockDatabase },
      ],
    }).compile();

    service = module.get<InventoryService>(InventoryService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all products', async () => {
      const mockProducts = [{ id: 1, product_name: 'Harina' }];
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue(mockProducts));

      const result = await service.findAll();
      expect(result).toEqual(mockProducts);
    });
  });

  describe('findOne', () => {
    it('should return a product by id', async () => {
      const mockProduct = { id: 1, product_name: 'Harina' };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockProduct]));

      const result = await service.findOne(1);
      expect(result).toEqual(mockProduct);
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.findOne(999)).rejects.toThrow(NotFoundException);
    });
  });

  describe('create', () => {
    it('should create a new product', async () => {
      const mockProduct = { id: 1, product_name: 'Harina', quantity: 50, price: 1.5 };
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([mockProduct]));

      const result = await service.create({
        productName: 'Harina',
        quantity: 50,
        price: 1.5,
        category: 'Ingredientes',
      });

      expect(result).toEqual(mockProduct);
    });
  });

  describe('remove', () => {
    it('should delete a product', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([{ id: 1 }]));

      const result = await service.remove(1);
      expect(result.msg).toBe('Product deleted successfully');
    });

    it('should throw NotFoundException if not found', async () => {
      mockDatabase.getSql.mockReturnValue(jest.fn().mockResolvedValue([]));

      await expect(service.remove(999)).rejects.toThrow(NotFoundException);
    });
  });
});
