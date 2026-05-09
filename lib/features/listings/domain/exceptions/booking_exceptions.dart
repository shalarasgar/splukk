class BookingException implements Exception {
  final String message;
  BookingException(this.message);

  @override
  String toString() => message;
}

class ListingNotFoundException extends BookingException {
  ListingNotFoundException() : super('LISTING_NOT_FOUND');
}

class InvalidScheduleException extends BookingException {
  InvalidScheduleException() : super('INVALID_SCHEDULE');
}

class SlotNotFoundException extends BookingException {
  SlotNotFoundException() : super('SLOT_NOT_FOUND');
}

class CapacityExceededException extends BookingException {
  CapacityExceededException() : super('CAPACITY_EXCEEDED');
}
