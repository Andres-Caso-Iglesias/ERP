import { IsNumber, IsDateString, IsOptional, IsString, Min } from 'class-validator';

export class CreateSaleDto {
  @IsNumber()
  clientId: number;

  @IsDateString()
  saleDate: string;

  @IsNumber()
  @Min(0.01)
  total: number;

  @IsOptional()
  @IsString()
  status?: string;
}
