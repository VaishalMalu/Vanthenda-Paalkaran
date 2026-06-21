// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_milk_card_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$customerMilkCardDataHash() =>
    r'88af2d6bb7743244a4f85d75050df69201fe09a5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [customerMilkCardData].
@ProviderFor(customerMilkCardData)
const customerMilkCardDataProvider = CustomerMilkCardDataFamily();

/// See also [customerMilkCardData].
class CustomerMilkCardDataFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [customerMilkCardData].
  const CustomerMilkCardDataFamily();

  /// See also [customerMilkCardData].
  CustomerMilkCardDataProvider call({
    required int month,
    required int year,
  }) {
    return CustomerMilkCardDataProvider(
      month: month,
      year: year,
    );
  }

  @override
  CustomerMilkCardDataProvider getProviderOverride(
    covariant CustomerMilkCardDataProvider provider,
  ) {
    return call(
      month: provider.month,
      year: provider.year,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'customerMilkCardDataProvider';
}

/// See also [customerMilkCardData].
class CustomerMilkCardDataProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [customerMilkCardData].
  CustomerMilkCardDataProvider({
    required int month,
    required int year,
  }) : this._internal(
          (ref) => customerMilkCardData(
            ref as CustomerMilkCardDataRef,
            month: month,
            year: year,
          ),
          from: customerMilkCardDataProvider,
          name: r'customerMilkCardDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$customerMilkCardDataHash,
          dependencies: CustomerMilkCardDataFamily._dependencies,
          allTransitiveDependencies:
              CustomerMilkCardDataFamily._allTransitiveDependencies,
          month: month,
          year: year,
        );

  CustomerMilkCardDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
    required this.year,
  }) : super.internal();

  final int month;
  final int year;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(
            CustomerMilkCardDataRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CustomerMilkCardDataProvider._internal(
        (ref) => create(ref as CustomerMilkCardDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
        year: year,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _CustomerMilkCardDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerMilkCardDataProvider &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CustomerMilkCardDataRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `month` of this provider.
  int get month;

  /// The parameter `year` of this provider.
  int get year;
}

class _CustomerMilkCardDataProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with CustomerMilkCardDataRef {
  _CustomerMilkCardDataProviderElement(super.provider);

  @override
  int get month => (origin as CustomerMilkCardDataProvider).month;
  @override
  int get year => (origin as CustomerMilkCardDataProvider).year;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
