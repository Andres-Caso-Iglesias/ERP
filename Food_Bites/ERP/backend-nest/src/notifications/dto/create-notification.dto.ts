import { IsNumber, IsString, MinLength, MaxLength } from 'class-validator';

export class CreateNotificationDto {
  @IsNumber()
  userId: number;

  @IsString()
  @MinLength(1)
  @MaxLength(500)
  message: string;
}
