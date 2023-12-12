import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class EventWidget extends StatelessWidget {
  final String time;
  final String title;
  final String evento;
  final String url;
  final IconData icon;

  const EventWidget({
    super.key,
    required this.time,
    required this.title,
    required this.evento,
    required this.url,
    required this.icon,
  });

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8.0),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () => _launchURL(url),
                      child: Text(
                        evento,
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .blue, // Optional: to make it look like a typical hyperlink
                          decoration:
                              TextDecoration.underline, // Optional: underline
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: NetworkImage(
                    url,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
