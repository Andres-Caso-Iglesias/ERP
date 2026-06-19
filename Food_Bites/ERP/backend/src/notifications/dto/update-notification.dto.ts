import { IsString, IsOptional, MinLength, MaxLength } from 'class-validator';

export class UpdateNotificationDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(500)
  message?: string;

  @IsOptional()
  @IsString()
  status?: string;
}
