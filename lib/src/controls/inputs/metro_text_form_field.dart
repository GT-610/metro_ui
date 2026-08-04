import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'metro_text_field.dart';

/// A [MetroTextField] integrated with Flutter's [Form] validation lifecycle.
class MetroTextFormField extends FormField<String> {
  MetroTextFormField({
    this.controller,
    String? initialValue,
    FocusNode? focusNode,
    Widget? label,
    String? placeholder,
    Widget? prefix,
    Widget? suffix,
    Widget? supportingText,
    Widget? successText,
    bool showSuccessWhenValid = false,
    MetroTextFieldStyle? style,
    super.enabled = true,
    bool readOnly = false,
    bool autofocus = false,
    bool obscureText = false,
    String obscuringCharacter = '•',
    bool autocorrect = true,
    bool enableSuggestions = true,
    Iterable<String>? autofillHints,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextAlign textAlign = TextAlign.start,
    int maxLines = 1,
    int? minLines,
    List<TextInputFormatter>? inputFormatters,
    this.onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    String? semanticLabel,
    super.onSaved,
    VoidCallback? onReset,
    super.forceErrorText,
    super.validator,
    super.errorBuilder,
    super.autovalidateMode,
    super.restorationId,
    super.key,
  }) : _resetCallback = _MetroResetCallback(onReset),
       assert(initialValue == null || controller == null),
       assert(!showSuccessWhenValid || validator != null),
       super(
         initialValue: controller?.text ?? initialValue ?? '',
         builder: (field) {
           final state = field as _MetroTextFormFieldState;
           final hasValidValue =
               showSuccessWhenValid &&
               field.hasInteractedByUser &&
               field.isValid;
           final validationState = field.hasError
               ? MetroTextFieldValidationState.error
               : hasValidValue
               ? MetroTextFieldValidationState.success
               : MetroTextFieldValidationState.none;
           final errorText = field.errorText;
           final effectiveSupportingText = errorText != null
               ? errorBuilder?.call(field.context, errorText) ?? Text(errorText)
               : hasValidValue
               ? successText ?? supportingText
               : supportingText;

           void handleChanged(String value) {
             field.didChange(value);
             onChanged?.call(value);
           }

           return MetroTextField(
             autofocus: autofocus,
             autocorrect: autocorrect,
             autofillHints: autofillHints,
             controller: state._effectiveController,
             enableSuggestions: enableSuggestions,
             enabled: enabled,
             focusNode: focusNode,
             inputFormatters: inputFormatters,
             keyboardType: keyboardType,
             label: label,
             maxLines: maxLines,
             minLines: minLines,
             obscureText: obscureText,
             obscuringCharacter: obscuringCharacter,
             onChanged: handleChanged,
             onEditingComplete: onEditingComplete,
             onSubmitted: onSubmitted,
             placeholder: placeholder,
             prefix: prefix,
             readOnly: readOnly,
             semanticLabel: semanticLabel,
             style: style,
             suffix: suffix,
             supportingText: effectiveSupportingText,
             textAlign: textAlign,
             textCapitalization: textCapitalization,
             textInputAction: textInputAction,
             validationState: validationState,
           );
         },
       );

  /// Creates a form field with the secure defaults of
  /// [MetroTextField.password].
  factory MetroTextFormField.password({
    TextEditingController? controller,
    String? initialValue,
    FocusNode? focusNode,
    Widget? label,
    String? placeholder,
    Widget? prefix,
    Widget? suffix,
    Widget? supportingText,
    Widget? successText,
    bool showSuccessWhenValid = false,
    MetroTextFieldStyle? style,
    bool enabled = true,
    bool readOnly = false,
    bool autofocus = false,
    String obscuringCharacter = '•',
    Iterable<String>? autofillHints = const <String>[AutofillHints.password],
    TextInputAction? textInputAction,
    TextAlign textAlign = TextAlign.start,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onEditingComplete,
    String? semanticLabel,
    FormFieldSetter<String>? onSaved,
    VoidCallback? onReset,
    String? forceErrorText,
    FormFieldValidator<String>? validator,
    FormFieldErrorBuilder? errorBuilder,
    AutovalidateMode? autovalidateMode,
    String? restorationId,
    Key? key,
  }) {
    return MetroTextFormField(
      autofocus: autofocus,
      autocorrect: false,
      autofillHints: autofillHints,
      autovalidateMode: autovalidateMode,
      controller: controller,
      enableSuggestions: false,
      enabled: enabled,
      errorBuilder: errorBuilder,
      focusNode: focusNode,
      forceErrorText: forceErrorText,
      initialValue: initialValue,
      inputFormatters: inputFormatters,
      key: key,
      keyboardType: TextInputType.visiblePassword,
      label: label,
      obscureText: true,
      obscuringCharacter: obscuringCharacter,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onReset: onReset,
      onSaved: onSaved,
      onSubmitted: onSubmitted,
      placeholder: placeholder,
      prefix: prefix,
      readOnly: readOnly,
      restorationId: restorationId,
      semanticLabel: semanticLabel,
      showSuccessWhenValid: showSuccessWhenValid,
      style: style,
      successText: successText,
      suffix: suffix,
      supportingText: supportingText,
      textAlign: textAlign,
      textInputAction: textInputAction,
      validator: validator,
    );
  }

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final _MetroResetCallback _resetCallback;

  /// Called after this field is reset to its initial value.
  // Flutter 3.32 does not declare FormField.onReset.
  // ignore: annotate_overrides
  VoidCallback? get onReset =>
      _resetCallback.callback == null ? null : _resetCallback.invoke;

  @override
  FormFieldState<String> createState() => _MetroTextFormFieldState();
}

class _MetroTextFormFieldState extends FormFieldState<String> {
  RestorableTextEditingController? _controller;

  TextEditingController get _effectiveController =>
      _textFormField.controller ?? _controller!.value;

  MetroTextFormField get _textFormField => widget as MetroTextFormField;

  void _createLocalController([TextEditingValue? value]) {
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      registerForRestoration(_controller!, 'controller');
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      registerForRestoration(_controller!, 'controller');
    }
    setValue(_effectiveController.text);
  }

  @override
  void initState() {
    super.initState();
    if (_textFormField.controller == null) {
      _createLocalController(TextEditingValue(text: value ?? ''));
    } else {
      _textFormField.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(MetroTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_textFormField.controller == oldWidget.controller) {
      return;
    }

    oldWidget.controller?.removeListener(_handleControllerChanged);
    _textFormField.controller?.addListener(_handleControllerChanged);
    if (oldWidget.controller != null && _textFormField.controller == null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (_textFormField.controller != null) {
      setValue(_textFormField.controller!.text);
      if (_controller != null) {
        unregisterFromRestoration(_controller!);
        _controller!.dispose();
        _controller = null;
      }
    }
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (_effectiveController.text != value) {
      _effectiveController.text = value ?? '';
    }
  }

  @override
  void reset() {
    final resetCallback = _textFormField._resetCallback..prepare();
    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
    resetCallback.invoke();
    _textFormField.onChanged?.call(_effectiveController.text);
  }

  void _handleControllerChanged() {
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }

  @override
  void dispose() {
    _textFormField.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }
}

class _MetroResetCallback {
  _MetroResetCallback(this.callback);

  final VoidCallback? callback;
  bool _invoked = false;

  void prepare() => _invoked = false;

  void invoke() {
    if (_invoked) {
      return;
    }
    _invoked = true;
    callback?.call();
  }
}
