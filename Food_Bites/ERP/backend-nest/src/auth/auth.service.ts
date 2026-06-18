import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { DatabaseService } from '../database/database.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  private readonly SALT_ROUNDS = 12;

  constructor(
    private readonly database: DatabaseService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const sql = this.database.getSql();

    // Check if username already exists
    const [existing] = await sql`
      SELECT id FROM users WHERE username = ${dto.username}
    `;

    if (existing) {
      throw new ConflictException('Username already exists');
    }

    // Hash password with bcrypt
    const hashedPassword = await bcrypt.hash(dto.password, this.SALT_ROUNDS);

    // Insert user
    const [user] = await sql`
      INSERT INTO users (username, password_hash)
      VALUES (${dto.username}, ${hashedPassword})
      RETURNING id, username
    `;

    return {
      msg: 'User registered successfully',
      user: { id: user.id, username: user.username },
    };
  }

  async login(dto: LoginDto) {
    const sql = this.database.getSql();

    // Find user
    const [user] = await sql`
      SELECT * FROM users WHERE username = ${dto.username}
    `;

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Compare password
    const passwordMatch = await bcrypt.compare(dto.password, user.password_hash);
    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Generate JWT
    const payload = { sub: user.id, username: user.username };
    const token = this.jwtService.sign(payload);

    return {
      msg: 'Login successful',
      token,
      user: {
        id: user.id,
        username: user.username,
      },
    };
  }

  async validateUser(userId: number) {
    const sql = this.database.getSql();
    const [user] = await sql`
      SELECT id, username FROM users WHERE id = ${userId}
    `;
    return user || null;
  }
}
