import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schoolapp/models/achievement_model.dart';
import 'package:schoolapp/models/social_models.dart';
import '../services/gamification_service.dart';


class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}


class _HubScreenState extends State<HubScreen> {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamification Hub'),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          conrtoller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
            Tab(icon: Icon(Icons.groups), text: 'Social'),
            Tab(icon: Icon(Icons.store), text: 'Shop'),
            Tab(icon: Icon(Icons.music_note), text: 'Music'),
            Tab(icon: Icon(Icons.pets), text: 'Pet'),
          ],
        ),
      ),

      body: Consumer<UltimateGamificationService>(
        builder: (context, service, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildProfileTab(service),
              _buildAchievementsTab(service),
              _buildSocialTab(service),
              _buildShopTab(service),
              _buildMusicTab(service),
              _buildPetTab(service),
            ],
          );
        },
      ),
    );
  }


  Widget _buildProfileTab(UltimateGamificationService service) {
    final profile = service.profile;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(
                        Icons.emoji_events, size: 60, color: Colors.amber),
                  ),
                  const SizedBox(height: 16),
                  Text(profile.userName,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                  const SizedBox (height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Level ${profile.level} ${profile.levelTitle}',
                          style: const TextStyle(fontSize: 18, color: Colors
                              .white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.rank,
                          style: TextStyle(
                            fontSize: 14,
                            color: profile.rankColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Text('XP Progress', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                )),

                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: profile.progressToNextLevel,
                    backgroundColor: Colors.grey[300],
                    color: Colors.purple,
                    minHeight: 10,
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${profile.currentXP} XP',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard(
                  'Total XP', '${profile.totalXP}', Icons.star, Colors.amber),
              _buildStatCard('Streak', '${profile.streakDays} days',
                  Icons.local_fire_department, Colors.red),
              _buildStatCard(
                  'Study Time', '${profile.totalStudyMinutes ~/ 60}h',
                  Icons.timer, Colors.blue),
              _buildStatCard(
                  'Assignments', '${profile.totalAssignmentsCopmleted}',
                  Icons.assignments_turned_in, Colors.green),
              _buildStatCard(
                  'Friends', '${service.friends.length}', Icons.people,
                  Colors.purple),
              _buildStatCard('Coins', '${service.coins}', Icons.monetization_on,
                  Colors.orange),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStatCard(String label, String value, IconData icon,
      Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(value,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }


  Widget _buildAchievemenggsTab(UltimateGamificationService service) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: service.profile.achievements.length,
      itemBuilder: (context, index) {
        final achievement = service.profile.achievements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: achievement.color.withOpacity(0.2),
                borderRadius: BorderRadius.all(25),
              ),
              child: Icon(achievement.icon, color: achievement.color, size: 30),
            ),
            title: Text(achievement.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(achievement.description),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('+${achievement.xpReward} XP',
                    style: const TextStyle(color: Colors.green, fontSize: 12)),
                if (achievement.unlockedAt != null)
                  Text('${achievement.unlockedAt!.day}/${achievement.unlockedAt!
                      .month}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildSocialTab(UltimateGamificationService service) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Frineds',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...service.friends.map((friend) =>
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(friend.userName),
                subtitle: Text('Friends since ${friend.since.year}'),
                trailing: const Icon(Icons.message),
                onTap: () {
                  //Opens the chat
                },
              ),
            )),

        const SizedBox(height: 24),

        const Text('Study Groups',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...service.studyGroups.map((group) =>
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.group)),
                title: Text(group.name),
                subtitle: Text(
                    '${group.members.length} members - ${group.subjects.join(
                        ', ')}'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  //opens the group
                },
              ),
            )),

        const SizedBox(height: 24),


        //Active challaneges
        const Text('Active Challenges',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...service.activeChallenges.map((challenge) =>
            Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: Text(challenge.title),
                subtitle: Text(challenge.description),
                trailing: Text('${challenge.xpReward} XP'),
              ),
            )),
      ],
    );
  }


  Widget _buildShopTab(UltimateGamificationService service) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),

      itemCount: service.shopItems.length,
      itemBuilder: (context, index) {
        final item = service.shopItems[index];
        return Card(
          child: Column(
            children: [
              Expanded(
                child: Icon(item.icon, size: 60, color: item.color),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(item.description, style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item.priceCoins > 0)
                          Row(
                            children: [
                              const Icon(Icons.monetization_on, size: 16,
                                  color: Colors.orange),
                              Text('${item.priceCoins}',
                                  style: const TextStyle(color: Colors.orange)),
                            ],
                          ),

                        if (item.priceXP > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                const Icon(
                                    Icons.star, size: 16, color: Colors.amber),
                                Text('${item.priceXP}', style: const TextStyle(
                                    color: Colors.amber)),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => service.purchaseItem(item.id),
                      child: const Text('Buy'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildMusicTab(UltimateGamificationService service) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: service.musicLibrary.length,
      itemBuilder: (context, index) {
        final music = service.musicLibrary[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(music.imageUrl),
              child: music.isPremium ? const Icon(Icons.star, size: 16) : null,
            ),

            title: Text(music.title),
            subtitle: Text(
                '${music.artist} ${music.durationSeconds ~/ 60} min'),
            trailing: IconButton(
              icon: Icon(
                  service.currentMusic?.id == music.id && service.isMusicPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
              onPressed: () {
                if (service.currentMusic?.id == music.id &&
                    service.isMusicPlaying) {
                  service.stopMusic();
                } else {
                  service.playMusic(music);
                }
              },
            ),
          ),
        );
      },
    );
  }


  Widget _buildPetTab(UltimateGamificationService service) {
    final pet = service.activePet;
    if (pet == null) return const Center(child: Text('No pet yet!'));

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: pet.statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPetIcon(pet.type),
              size: 120,
              color: pet.statusColor,
            ),
          ),

          const SizedBox(height: 24),
          Text(pet.name, style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Level ${pet.level}', style: const TextStyle(fontSize: 18)),
          Text(pet.status,
              style: TextStyle(color: pet.statusColor, fontSize: 16)),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: pet.progressToNextLevel,
            backgroundColor: Colors.grey[300],
            color: pet.statusColor,
            minHeight: 10,
          ),

          const SizedBox(height: 8),
          Text('${pet.experience}/${pet.nextLevelXP} XP to nxt lvl'),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: pet.feed,
                icon: const Icon(Icons.restaurant),
                label: const Text ('feed'),
              ),

              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: pet.play,
                icon: const Icon(Icons.gamepad),
                label: const Text('Play'),
              ),

              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: pet.sleep,
                icon: const Icon(Icons.bed),
                label: const Text('Sleep'),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),

            child: Column(
              children: [
                const Text(
                    'Stats', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Hunger: ${pet.hunger}/${pet.maxHunger}'),
                Text('Happiness: ${pet.happiness}/${pet.maxHappiness}'),
                Text('Energy: ${pet.energy}/${pet.maxEnergy}'),
              ],
            ),
          ),
        ],
      ),
    );
  }


  IconData _getPetIcon(PetType type) {
    switch (type) {
      case PetType.dragon:
        return Icons.dragon;
      case PetType.pheonix:
        return Icons.whatshot;
      case PetType.owl:
        return Icons.school;
      case PetType.cat:
        return Icons.pets;
      case PetType.dog:
        return Icons.pets;
      case PetType.fox:
        return Icons.wildlife;
      case PetType.wolf:
        return Icons.wildlife;
      case PetType.unicord:
        return Icons.auto_awesome;
        deafult:
        return Icons.pets;
    }
  }
}
