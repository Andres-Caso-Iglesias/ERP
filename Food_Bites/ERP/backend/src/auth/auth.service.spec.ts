import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { DatabaseService } from '../database/database.service';
import { JwtService } from '@nestjs/jwt';
import { ConflictException, UnauthorizedException } from '@nestjs/common';

describe('AuthService', () => {
  let service: AuthService;
  let mockDatabase: { getSql: jest.Mock };
  let mockJwt: { sign: jest.Mock };

  beforeEach(async () => {
    mockDatabase = { getSql: jest.fn() };
    mockJwt = { sign: jest.fn().mockReturnValue('mock-token') };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: DatabaseService, useValue: mockDatabase },
        { provide: JwtService, useValue: mockJwt },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('register', () => {
    it('should register a new user successfully', async () => {
      const mockSql = jest.fn().mockResolvedValue([{ id: 1, username: 'testuser' }]);
      mockDatabase.getSql.mockReturnValue(mockSql);

      const result = await service.register({
        username: 'testuser',
        password: 'Test123!',
      });

      expect(result.msg).toBe('User registered successfully');
      expect(result.user.username).toBe('testuser');
    });

    it('should throw ConflictException if username exists', async () => {
      const mockSql = jest.fn()
        .mockResolvedValueOnce([{ id: 1 }]) // existing user check
        .mockRejectedValueOnce({ code: '23505' }); // duplicate key
      mockDatabase.getSql.mockReturnValue(mockSql);

      await expect(
        service.register({ username: 'existing', password: 'Test123!' }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('login', () => {
    it('should throw UnauthorizedException for invalid credentials', async () => {
      const mockSql = jest.fn().mockResolvedValue([]); // no user found
      mockDatabase.getSql.mockReturnValue(mockSql);

      await expect(
        service.login({ username: 'wrong', password: 'wrong' }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('validateUser', () => {
    it('should return user if found', async () => {
      const mockSql = jest.fn().mockResolvedValue([{ id: 1, username: 'test' }]);
      mockDatabase.getSql.mockReturnValue(mockSql);

      const result = await service.validateUser(1);
      expect(result.username).toBe('test');
    });

    it('should return null if not found', async () => {
      const mockSql = jest.fn().mockResolvedValue([]);
      mockDatabase.getSql.mockReturnValue(mockSql);

      const result = await service.validateUser(999);
      expect(result).toBeNull();
    });
  });
});
