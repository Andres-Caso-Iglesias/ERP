import { IsString, IsNumber, IsDateString, IsOptional, MinLength, MaxLength, Min } from 'class-validator';

export class CreateEntryDto {
  @IsDateString()
  transactionDate: string;

  @IsString()
  @MinLength(1)
  @MaxLength(255)
  description: string;

  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsString()
  @MinLength(1)
  @MaxLength(20)
  type: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  category?: string;
}
