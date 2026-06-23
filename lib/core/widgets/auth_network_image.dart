import 'package:flutter/material.dart';
import '../storage/secure_storage.dart';

class AuthNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext context)? placeholderBuilder;
  final Widget Function(BuildContext context, Object error)?
      errorBuilderWidget;

  const AuthNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholderBuilder,
    this.errorBuilderWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SecureStorageService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return placeholderBuilder?.call(context) ?? const SizedBox.shrink();
        }

        final token = snapshot.data;
        final uri = Uri.tryParse(imageUrl);
        final isSignedUrl =
            uri != null && uri.queryParameters.containsKey('signature');
        final headers =
            token == null || token.isEmpty || isSignedUrl
                ? null
                : {'Authorization': 'Bearer $token'};

        return Image.network(
          imageUrl,
          fit: fit,
          headers: headers,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return placeholderBuilder?.call(context) ?? const SizedBox.shrink();
          },
          errorBuilder: (context, error, _) {
            return errorBuilderWidget?.call(context, error) ??
                const SizedBox.shrink();
          },
        );
      },
    );
  }
}
