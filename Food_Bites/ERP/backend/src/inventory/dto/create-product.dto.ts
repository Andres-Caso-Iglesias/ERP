import { IsString, IsNumber, Min, MaxLength, MinLength } from 'class-validator';

export class CreateProductDto {
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  productName: string;

  @IsNumber()
  @Min(0)
  quantity: number;

  @IsNumber()
  @Min(0.01)
  price: number;

  @IsString()
  @MinLength(1)
  @MaxLength(50)
  category: string;
}
