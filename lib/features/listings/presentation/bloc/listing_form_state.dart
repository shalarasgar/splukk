import 'package:equatable/equatable.dart';

abstract class ListingFormState extends Equatable {
  const ListingFormState();

  @override
  List<Object?> get props => [];
}

class ListingFormInitial extends ListingFormState {}

class ListingFormSaving extends ListingFormState {}

class ListingFormSuccess extends ListingFormState {}

class ListingFormFailure extends ListingFormState {
  final String errorMessage;

  const ListingFormFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
