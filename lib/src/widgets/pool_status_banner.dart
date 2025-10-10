import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:floatit/src/pool_status_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/services/rate_limit_service.dart';

/// A persistent banner that displays the pool status at the bottom of the screen
class PoolStatusBanner extends StatelessWidget {
  const PoolStatusBanner({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<PoolStatusProvider>(
      builder: (context, provider, child) {
        final status = provider.currentStatus;
        
        // Don't show banner if there's no status
        if (status == null || status.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final isNormal = provider.isNormalStatus;
        final backgroundColor = isNormal 
          ? Colors.green.shade100 
          : Colors.orange.shade100;
        final textColor = isNormal 
          ? Colors.green.shade900 
          : Colors.orange.shade900;
        final iconColor = isNormal 
          ? Colors.green.shade700 
          : Colors.orange.shade700;
        
        return Material(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: isNormal ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isNormal ? Icons.check_circle : Icons.warning,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sundby Bad Status: $status',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: iconColor,
                    size: 20,
                  ),
                  onPressed: provider.isLoading ? null : () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;
                    
                    final rateLimitService = RateLimitService.instance;
                    if (!rateLimitService.isActionAllowed(user.uid, RateLimitAction.poolRefresh)) {
                      return;
                    }
                    
                    rateLimitService.recordAction(user.uid, RateLimitAction.poolRefresh);
                    provider.forceRefresh(user.uid);
                  },
                  tooltip: 'Refresh status',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
