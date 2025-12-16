// Shared types for Edge Functions

export interface BookingData {
  guide_id: string;
  visitor_id: string;
  service_id: string;
  booking_date: string;
  time_slot: string;
  number_of_participants: number;
  pickup_location?: string;
  destinations?: string[];
  special_requests?: string;
  total_amount: number;
}

export interface PaymentIntentData {
  id: string;
  client_secret: string;
  amount: number;
  currency: string;
  status: string;
}

export interface NotificationPayload {
  user_id: string;
  title: string;
  body: string;
  data?: Record<string, any>;
}

export interface PayoutData {
  guide_id: string;
  amount: number;
  period_start: string;
  period_end: string;
  bookings: string[];
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}
