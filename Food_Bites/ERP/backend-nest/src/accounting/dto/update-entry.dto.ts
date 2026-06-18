import { IsString, IsNumber, IsDateString, IsOptional, MinLength, MaxLength, Min } from 'class-validator';

export class UpdateEntryDto {
  @IsOptional()
  @IsDateString()
  transactionDate?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(255)
  description?: string;

  @IsOptional()
  @IsNumber()
  @Min(0.01)
  amount?: number;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(20)
  type?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  category?: string;
}
