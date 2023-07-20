import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/providers/auth_provider.dart';

import '../pages/auth_page.dart';

class AuthCard extends ConsumerStatefulWidget {
  const AuthCard({
    super.key,
  });

  @override
  ConsumerState<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends ConsumerState<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _isObscure = true;
  bool _isObscure1 = true;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _opacityAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, -1.5), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // For continuos animations...
    // _controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     _switchAuthMode();
    //   } else if (status == AnimationStatus.dismissed) {
    //     _switchAuthMode();
    //   }
    // });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 500),
        onEnd: () {},
        height: _authMode == AuthMode.signUp ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.signUp ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: _buildForm(context),
      ),
    );
  }

  Form _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'E-Mail'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
              validator: (value) {
                if (value != null) {
                  if (value.isEmpty || !value.contains('@')) {
                    return 'Invalid email!';
                  }
                  return null;
                } else {
                  return 'Field can\'t be empty';
                }
              },
              onSaved: (value) {
                _authData['email'] = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    }),
              ),
              obscureText: _isObscure,
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              textInputAction: _authMode == AuthMode.login
                  ? TextInputAction.done
                  : TextInputAction.next,
              onFieldSubmitted: _authMode == AuthMode.login
                  ? (_) => _submit()
                  : (_) => _confirmPasswordFocusNode.requestFocus(),
              focusNode: _passwordFocusNode,
              validator: (value) {
                if (value != null) {
                  if (value.length < 6) {
                    return 'Password should be atleast 6 characters long!';
                  }
                  return null;
                } else {
                  return 'Field can\'t be empty';
                }
              },
              onSaved: (value) {
                _authData['password'] = value!;
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              constraints: BoxConstraints(
                minHeight: _authMode == AuthMode.signUp ? 60 : 0,
                maxHeight: _authMode == AuthMode.signUp ? 120 : 0,
              ),
              curve: Curves.easeIn,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: TextFormField(
                    enabled: _authMode == AuthMode.signUp,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                          icon: Icon(_isObscure1
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isObscure1 = !_isObscure1;
                            });
                          }),
                    ),
                    obscureText: _isObscure1,
                    textInputAction: TextInputAction.done,
                    focusNode: _confirmPasswordFocusNode,
                    onFieldSubmitted: (_) => _submit(),
                    validator: _authMode == AuthMode.signUp
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _submit,
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                  ),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all(Theme.of(context).primaryColor),
                  foregroundColor: const MaterialStatePropertyAll(Colors.white),
                ),
                child: Text(_authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP'),
              ),
            TextButton(
              onPressed: _switchAuthMode,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                  '${_authMode == AuthMode.login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(
      () => _isLoading = true,
    );
    if (_authMode == AuthMode.login) {
      await ref.read(authenticationProvider).signInWithEmailAndPassword(
          _authData['email']!, _authData['password']!, context);
    } else {
      await ref.read(authenticationProvider).signUpWithEmailAndPassword(
          _authData['email']!, _authData['password']!, context);
    }
    setState(
      () => _isLoading = false,
    );
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
      _controller.reverse();
    }
  }
}
