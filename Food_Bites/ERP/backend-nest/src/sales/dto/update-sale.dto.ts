import { IsNumber, IsDateString, IsOptional, IsString, Min } from 'class-validator';

export class UpdateSaleDto {
  @IsOptional()
  @IsNumber()
  clientId?: number;

  @IsOptional()
  @IsDateString()
  saleDate?: string;

  @IsOptional()
  @IsNumber()
  @Min(0.01)
  total?: number;

  @IsOptional()
  @IsString()
  status?: string;
}
