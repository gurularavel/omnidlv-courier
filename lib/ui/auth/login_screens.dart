import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/phone_format.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../state/providers.dart';
import '../theme.dart';
import '../widgets.dart';

class _AuthFrame extends StatelessWidget {
  const _AuthFrame({required this.children, this.leading});
  final List<Widget> children;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(leading: leading, automaticallyImplyLeading: false),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: children),
            ),
          ),
        ),
      );
}

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _phone = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final demo = await ref.read(sessionProvider.notifier).requestCode(_phone.text);
      if (mounted) context.push('/login/code', extra: (phone: _phone.text, demoCode: demo));
    } on ApiException catch (e) {
      setState(() => _error = e.firstError('phone') ?? errorText(t, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _AuthFrame(children: [
      Text(t.appTitle.toUpperCase(), style: Typo.label),
      const SizedBox(height: 12),
      Text(t.phoneTitle, style: Typo.display),
      const SizedBox(height: 8),
      Text(t.phoneBody, style: const TextStyle(color: Palette.text2)),
      const SizedBox(height: 24),
      Text(t.phoneLabel.toUpperCase(), style: Typo.label),
      const SizedBox(height: 8),
      TextField(
        controller: _phone,
        autofocus: true,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumber],
        // Digits only, grouped as typed: letters never reach the field.
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]')), PhoneInputFormatter()],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 1),
        decoration: InputDecoration(hintText: '050 123 45 67', errorText: _error),
        onSubmitted: (_) => _send(),
      ),
      const SizedBox(height: 16),
      FilledButton(onPressed: _busy ? null : _send, child: Text(t.sendCode.toUpperCase())),
    ]);
  }
}

class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({super.key, required this.phone, this.demoCode});
  final String phone;
  final String? demoCode;

  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends ConsumerState<CodeScreen> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _demo;

  @override
  void initState() {
    super.initState();
    _demo = widget.demoCode;
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final t = AppLocalizations.of(context);
    if (_code.text.length != 6) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).verify(widget.phone, _code.text);
      // The router moves on once the session is signed in.
    } on ApiException catch (e) {
      setState(() => _error = e.firstError('code') ?? errorText(t, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      final demo = await ref.read(sessionProvider.notifier).requestCode(widget.phone);
      setState(() => _demo = demo);
    } on ApiException catch (e) {
      if (mounted) showMessage(context, errorText(AppLocalizations.of(context), e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return _AuthFrame(
      leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop(), tooltip: t.changeNumber),
      children: [
        Text(t.codeTitle, style: Typo.display),
        const SizedBox(height: 8),
        Text(t.codeSentTo(formatPhone(widget.phone)), style: const TextStyle(color: Palette.text2)),
        if (_demo != null) ...[
          const SizedBox(height: 16),
          NoticeBanner(t.demoSms(_demo!), icon: Icons.sms_outlined),
        ],
        const SizedBox(height: 24),
        Text(t.codeLabel.toUpperCase(), style: Typo.label),
        const SizedBox(height: 8),
        TextField(
          controller: _code,
          autofocus: true,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 10),
          decoration: InputDecoration(errorText: _error, counterText: ''),
          onChanged: (v) {
            if (v.length == 6) _verify();
          },
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _busy ? null : _verify, child: Text(t.signIn.toUpperCase())),
        const SizedBox(height: 8),
        TextButton(onPressed: _resend, child: Text(t.resendCode)),
      ],
    );
  }
}
