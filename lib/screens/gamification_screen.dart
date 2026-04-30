import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gamification_service.dart';
import '../models/achievement_model.dart';



class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievments & Progress'),
        backgroundColor: Colors.purple,
      ),
      body: Consumer<GamificationService>(
        builder: (context, service, child) {
          final profile = service.profile;
          return CustomScrollView(
            slivers: [

              //Profile heder
              SliverToBoxAdapter(
                child: _buildProfileHeader(profile, service),
              ),

              //Level Progress
              SliverToBoxAdapter(
                child: _buildLevelProgress(profile, service),
              ),

              //Stats casts
              SliverToBoxAdapter(
                child: _buildStatsCards(profile),
              ),

              //Achv section
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text('Achievements',
                    style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold),),

                    const SizedBox(height: 16),
                    ...service.unlockedAchievements.map((a) => _buildAchievementCard(a, true)),

                    if (service.lockedAchievements.isNotEmpty) 
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Locked Achievements', 
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                        ),),
                    ),
                      ...service.lockedAchievements.map((a) => _buildAchievementCard(a, false)),
                  ]),
                ),
              ),
            ],
          );
        },
      ),    
    );
  }


  Widget _buildProfileHeader(UserProfile profile, GamificationService service) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade700, Colors.purple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.emoji_events, size: 50, color: Colors.amber),            
              ),
              const SizedBox(height: 16),
              Text(
                profile.userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Level ${profile.level}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],          
        ),
      ),
    );
  }



  Widget _buildLevelProgress(UserProfile profile, GamificationService service) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progress to next lvl',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  Text('${profile.currentXP} / ${profile.nextLrvrlXP} XP',
                  style: const  TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: service.levelProgress,
                backgroundColor: Colors.grey[300],
                color: Colors.purple,
                minHeight: 10,
              ),
              const SizedBox(height: 8),
              Text('Total XP: ${profile.totalXP}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }



    Widget _buildStatsCards(UserProfile profile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
              Expanded(
                child: _buildStatCard('Total XP', 
                '${profile.totalXP}',
                Colors.orange,
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Streak',
                '${profile.streakDays} days',
                Colors.red,
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Completed',
                '${profile.totalAssignmentsCopmleted}',
                Colors.green,
                ),
              ),
          ],
        ),
      );
    }


      
      Widget _buildStatCard(String label, String value, Color color) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  label, 
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 4),
                Text(value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                ),
              ],
            ),
          ),
        );
      }



      Widget _buildAchievementCard(Achievement achievement, bool unlocked) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: unlocked ? achievement.color.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),

              child: Icon(
                achievement.icon,
                color: unlocked ? achievement.color : Colors.grey,
                size: 30,
              ),
            ),

            title: Text(
              achievement.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: unlocked ? Colors.black : Colors.grey,
              ),
            ),

            subtitle: Text(
              achievement.description,
              style: TextStyle(color: unlocked ? Colors.grey[600] : Colors.grey[400]),
            ),
            trailing: unlocked ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Text('Unlocked',
              style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ) : Text('${achievement.requiredCount} required',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      }
}