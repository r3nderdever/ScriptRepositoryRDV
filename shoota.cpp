#include <SFML/Graphics.hpp>
#include <SFML/Window.hpp>
#include <cmath>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <algorithm>
#include <iostream>

using namespace sf;

float distance(Vector2f a, Vector2f b) {
    return std::sqrt((a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y));
}

enum EnemyType { BASIC, FAST, TANK, BOSS, SNIPER, SWARMER, BOMBER, PHASER };

struct Enemy {
    Vector2f pos;
    Vector2f vel;
    int health;
    int maxHealth;
    float speed;
    EnemyType type;
    float hitFlashTime = 0.0f;
    float specialTimer = 0.0f;
};

struct Bullet {
    Vector2f pos;
    Vector2f vel;
    int pierce;
    std::vector<Vector2f> trail;
};

struct Explosion {
    Vector2f pos;
    float time;
};

struct Particle {
    Vector2f pos, vel;
    float lifetime;
    Color color;
};

int main() {
    srand(static_cast<unsigned>(time(0)));
    RenderWindow window(VideoMode(1200, 800), "Top-Down Gun Game");
    window.setFramerateLimit(60);

    View camera(FloatRect(0, 0, 1200, 800));

    Vector2f playerPos(600, 400);
    float playerSpeed = 4.0f;
    int kills = 0;
    bool dashing = false;
    float dashCooldown = 1.0f;
    float dashTimer = 0;

    std::vector<Enemy> enemies;
    std::vector<Bullet> bullets;
    std::vector<Explosion> explosions;
    std::vector<Particle> particles;
    int wave = 1;
    float shootCooldown = 0.15f;
    float shootTimer = 0.0f;
    float shakeTime = 0;
    float screenFlash = 0;
    float enemySpawnTimer = 0;
    int toSpawn = 0;

    Font font;
    if (!font.loadFromFile("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")) {
        std::cerr << "Failed to load font!\n";
        return -1;
    }

    auto spawnEnemy = [&](EnemyType type) {
        Vector2f pos;
        do {
            pos.x = rand() % 1200;
            pos.y = rand() % 800;
        } while (distance(pos, playerPos) < 100);

        int health;
        float speed;
        switch (type) {
            case BASIC: health = 2; speed = 1.0f; break;
            case FAST: health = 1; speed = 1.8f; break;
            case TANK: health = 5; speed = 0.5f; break;
            case BOSS: health = 20 + wave * 2; speed = 0.6f; break;
            case SNIPER: health = 2; speed = 0.3f; break;
            case SWARMER: health = 1; speed = 2.5f; break;
            case BOMBER: health = 3; speed = 0.8f; break;
            case PHASER: health = 3; speed = 1.0f; break;
        }

        enemies.push_back({pos, Vector2f(0, 0), health, health, speed, type});
    };

    auto scheduleEnemies = [&](int num) {
        toSpawn = num;
        enemySpawnTimer = 0.0f;
    };

    scheduleEnemies(1);

    Clock deltaClock;
    while (window.isOpen()) {
        float dt = std::min(0.05f, deltaClock.restart().asSeconds());

        Event event;
        while (window.pollEvent(event)) {
            if (event.type == Event::Closed)
                window.close();
        }

        Vector2f move(0, 0);
        if (Keyboard::isKeyPressed(Keyboard::W)) move.y -= 1;
        if (Keyboard::isKeyPressed(Keyboard::S)) move.y += 1;
        if (Keyboard::isKeyPressed(Keyboard::A)) move.x -= 1;
        if (Keyboard::isKeyPressed(Keyboard::D)) move.x += 1;

        dashTimer -= dt;
        static float dashProgress = 0.0f;
        static Vector2f dashStart;
        static Vector2f dashDir;

        if (Keyboard::isKeyPressed(Keyboard::Space) && dashTimer <= 0 && (move.x != 0 || move.y != 0)) {
            float len = std::sqrt(move.x * move.x + move.y * move.y);
            dashDir = move / len;
            dashStart = playerPos;
            dashProgress = 0.0f;
            dashing = true;
            dashTimer = dashCooldown;
        }

        if (dashing) {
            dashProgress += dt * 3;
            if (dashProgress >= 1.0f) {
                dashProgress = 1.0f;
                dashing = false;
            }
            float eased = 1 - std::pow(1 - dashProgress, 3);
            playerPos = dashStart + dashDir * eased * 400.0f;
        } else if (move.x != 0 || move.y != 0) {
            float len = std::sqrt(move.x * move.x + move.y * move.y);
            playerPos += move / len * playerSpeed;
        }

        shootTimer -= dt;
        if (Mouse::isButtonPressed(Mouse::Left) && shootTimer <= 0) {
            Vector2i pixelPos = Mouse::getPosition(window);
            Vector2f mousePos = window.mapPixelToCoords(pixelPos);
            Vector2f dir = mousePos - playerPos;
            float len = std::sqrt(dir.x * dir.x + dir.y * dir.y);
            if (len == 0) len = 1;
            dir /= len;

            int projectiles = 1 + (wave - 1) / 6;
            for (int i = 0; i < projectiles; ++i) {
                float spread = 0.05f * (projectiles - 1);
                float angle = (float(i) - (projectiles - 1) / 2.0f) * spread;
                float cs = std::cos(angle), sn = std::sin(angle);
                Vector2f rotatedDir = {dir.x * cs - dir.y * sn, dir.x * sn + dir.y * cs};
                bullets.push_back({playerPos, rotatedDir * 1200.0f, 1 + kills / 3});
                for (int p = 0; p < 5; ++p)
                    particles.push_back({playerPos, rotatedDir * 200.f + Vector2f((rand()%100-50)/50.f, (rand()%100-50)/50.f)*30.f, 0.2f, Color::Yellow});
            }

            shootTimer = shootCooldown;
        }

        for (auto& b : bullets) {
            b.trail.push_back(b.pos);
            if (b.trail.size() > 10) b.trail.erase(b.trail.begin());
            b.pos += b.vel * dt;
        }

        bullets.erase(std::remove_if(bullets.begin(), bullets.end(), [&](Bullet& b) {
            return b.pos.x < -100 || b.pos.x > 1300 || b.pos.y < -100 || b.pos.y > 900;
        }), bullets.end());

        std::vector<Bullet> nextBullets;
        for (auto& b : bullets) {
            bool hit = false;
            for (auto& e : enemies) {
                if (e.health > 0 && distance(b.pos, e.pos) < 20) {
                    e.health--;
                    e.hitFlashTime = 0.1f;
                    b.pierce--;
                    hit = true;
                    for (int i = 0; i < 10; ++i)
                        particles.push_back({e.pos, Vector2f((rand()%200-100)/100.f, (rand()%200-100)/100.f)*100.f, 0.3f, Color::Red});
                    break;
                }
            }
            if (!hit || b.pierce > 0)
                nextBullets.push_back(b);
        }
        bullets = nextBullets;

        enemySpawnTimer += dt;
        if (toSpawn > 0 && enemySpawnTimer >= 0.4f) {
            enemySpawnTimer = 0.0f;
            toSpawn--;
            int r = rand() % 100;
            if (r < 30) spawnEnemy(BASIC);
            else if (r < 50) spawnEnemy(FAST);
            else if (r < 65) spawnEnemy(TANK);
            else if (r < 75) spawnEnemy(SWARMER);
            else if (r < 85) spawnEnemy(SNIPER);
            else if (r < 95) spawnEnemy(BOMBER);
            else spawnEnemy(PHASER);
        }

        for (auto& e : enemies) {
            if (e.health <= 0) continue;
            e.specialTimer += dt;

            Vector2f toPlayer = playerPos - e.pos;
            float len = std::sqrt(toPlayer.x * toPlayer.x + toPlayer.y * toPlayer.y);
            if (len != 0) toPlayer /= len;

            switch (e.type) {
                case SNIPER:
                    if (e.specialTimer > 3.0f) {
                        e.specialTimer = 0;
                        bullets.push_back({e.pos, toPlayer * 900.0f, 1});
                    }
                    break;
                case SWARMER:
                    e.speed = 3.0f;
                    break;
                case BOMBER:
                    if (len < 30 && e.specialTimer > 2.0f) {
                        e.specialTimer = 0;
                        explosions.push_back({e.pos, 0.8f});
                        e.health = 0;
                        for (int i = 0; i < 30; ++i)
                            particles.push_back({e.pos, Vector2f((rand()%200-100)/100.f, (rand()%200-100)/100.f)*200.f, 0.5f, Color::Yellow});
                    }
                    break;
                case PHASER:
                    if (e.specialTimer > 4.0f) {
                        e.specialTimer = 0;
                        e.pos.x = rand() % 1200;
                        e.pos.y = rand() % 800;
                        for (int i = 0; i < 10; ++i)
                            particles.push_back({e.pos, Vector2f((rand()%200-100)/100.f, (rand()%200-100)/100.f)*50.f, 0.4f, Color::Cyan});
                    }
                    break;
                default: break;
            }

            e.vel = toPlayer * e.speed;
            e.pos += e.vel * dt;
            e.hitFlashTime -= dt;
        }

        std::vector<Enemy> remaining;
        for (auto& e : enemies) {
            if (e.health <= 0) {
                kills++;
                explosions.push_back({e.pos, 0.5f});
                shakeTime = 0.2f;
                for (int i = 0; i < 15; ++i) {
                    particles.push_back({e.pos, Vector2f((rand()%200-100)/100.f, (rand()%200-100)/100.f)*100.f, 0.5f, Color(255, 50, 0)});
                }
                continue;
            }
            if (distance(e.pos, playerPos) < 20) {
                playerPos = Vector2f(600, 400);
                enemies.clear();
                bullets.clear();
                kills = 0;
                shootCooldown = 0.15f;
                wave = 1;
                scheduleEnemies(1);
                break;
            }
            remaining.push_back(e);
        }
        enemies = remaining;

        for (auto& ex : explosions) ex.time -= dt;
        explosions.erase(std::remove_if(explosions.begin(), explosions.end(), [](Explosion& ex) { return ex.time <= 0; }), explosions.end());

        for (auto& p : particles) {
            p.lifetime -= dt;
            p.pos += p.vel * dt;
        }
        particles.erase(std::remove_if(particles.begin(), particles.end(), [](Particle& p) { return p.lifetime <= 0; }), particles.end());

        if (enemies.empty() && toSpawn == 0) {
            wave++;
            scheduleEnemies(std::max(2, (int)std::pow(2, wave - 1)));
        }

        Vector2f camCenter = camera.getCenter();
        Vector2f toTarget = playerPos - camCenter;
        camera.setCenter(camCenter + toTarget * 5.0f * dt);
        if (shakeTime > 0) {
            shakeTime -= dt;
            camera.move(Vector2f(rand()%10 - 5, rand()%10 - 5));
        }
        window.setView(camera);

        window.clear(Color(30 + std::min(255, int(screenFlash * 600)), 30, 30));

        CircleShape player(15);
        player.setOrigin(15, 15);
        player.setPosition(playerPos);
        player.setFillColor(Color::White);
        window.draw(player);

        for (auto& b : bullets) {
            for (size_t i = 1; i < b.trail.size(); ++i) {
                Vertex line[] = {
                    Vertex(b.trail[i - 1], Color(255, 255, 0, 100)),
                    Vertex(b.trail[i], Color(255, 255, 0, 50))
                };
                window.draw(line, 2, Lines);
            }
            CircleShape bullet(4);
            bullet.setOrigin(4, 4);
            bullet.setPosition(b.pos);
            bullet.setFillColor(Color::Yellow);
            window.draw(bullet);
        }

        for (auto& e : enemies) {
            float radius = (e.type == BOSS) ? 25 : 15;
            CircleShape enemy(radius);
            enemy.setOrigin(radius, radius);
            enemy.setPosition(e.pos);
            Color color;
            switch (e.type) {
                case BASIC: color = Color(200, 0, 0); break;
                case FAST: color = Color(255, 100, 100); break;
                case TANK: color = Color(100, 0, 0); break;
                case BOSS: color = Color(50, 0, 100); break;
                case SNIPER: color = Color(200, 200, 255); break;
                case SWARMER: color = Color(0, 255, 100); break;
                case BOMBER: color = Color(255, 200, 0); break;
                case PHASER: color = Color::Cyan; break;
            }
            if (e.hitFlashTime > 0) color = Color::White;
            enemy.setFillColor(color);
            window.draw(enemy);

            RectangleShape hp(Vector2f(radius * 2 * (float)e.health / e.maxHealth, 4));
            hp.setFillColor(Color::Red);
            hp.setPosition(e.pos.x - radius, e.pos.y - radius - 8);
            window.draw(hp);
        }

        for (auto& ex : explosions) {
            float size = 40 * (1.0f - ex.time / 0.5f);
            CircleShape boom(size);
            boom.setOrigin(size, size);
            boom.setPosition(ex.pos);
            boom.setFillColor(Color(255, 100, 0, 150));
            window.draw(boom);
        }

        for (auto& p : particles) {
            CircleShape dot(2);
            dot.setOrigin(2, 2);
            dot.setPosition(p.pos);
            dot.setFillColor(p.color);
            window.draw(dot);
        }

        Text uiText("Kills: " + std::to_string(kills) + " | Wave: " + std::to_string(wave), font, 20);
        uiText.setFillColor(Color::White);
        uiText.setPosition(10, 10);
        window.setView(window.getDefaultView());
        window.draw(uiText);
        window.setView(camera);

        window.display();
    }
    return 0;
}
