// pomodoro.cpp - Pomodoro Timer Daemon for i3/Polybar (v2)
//
// Compile: g++ -std=c++17 -O2 -o pomodoro pomodoro.cpp -pthread
//
// Usage:
//   pomodoro --daemon     Start background daemon
//   pomodoro --start      Start/restart 25-min timer (SIGUSR1)
//   pomodoro --break      Trigger break popup manually (SIGUSR2)
//   pomodoro --status     Print current state
//   pomodoro --stop       Stop the daemon gracefully

#include <atomic>
#include <chrono>
#include <csignal>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <fcntl.h>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <sys/stat.h>
#include <thread>
#include <unistd.h>

// ============================================================================
// CONFIGURATION
// ============================================================================
namespace Config {
constexpr int POMODORO_MINUTES = 25;
constexpr int POMODORO_SECONDS = POMODORO_MINUTES * 60;

// Polling interval - smaller = more responsive to signals
constexpr int POLL_INTERVAL_MS = 100;
constexpr int POLLS_PER_SECOND = 1000 / POLL_INTERVAL_MS; // 10

// File paths
inline std::string get_state_file() {
    return "/tmp/pomodoro.state";
}

inline std::string get_pid_file() {
    return "/tmp/pomodoro.pid";
}

// Rofi popup command - uses theme if available
inline std::string get_popup_cmd() {
    // const char *home = std::getenv("HOME");
    // std::string theme_path = std::string(home) + "/.config/cus-pomodoro/pomodoro.rasi";

    // Check if custom theme exists
    // struct stat st;
    // if (stat(theme_path.c_str(), &st) == 0) {
    //     return "rofi -e '🍅 Break Time!' ";
    //     return
    // "-theme " +
    // theme_path;
    // }

    // Fallback to inline styling
    // Change get_popup_cmd() to return:
    // return "bash -c 'while true; do "
    //        "RESULT=$(echo -e \"Continue\" | rofi -dmenu -p \"🍅 Break Time!\" "
    //        "-theme-str \"window {width: 400px;}\" "
    //        "-theme-str \"listview {enabled: false;}\" "
    //        "-theme-str \"inputbar {children: [prompt];}\" "
    //        "-kb-cancel \"Escape,Escape\"); "
    //        "[ -z \"$RESULT\" ] && break; done'";
    return "rofi -e '☕ Break Time !Step away.Stretch.Breathe.' -theme $HOME/.config/rofi/pomodoro.rasi";
}
} // namespace Config

// ============================================================================
// STATE MANAGEMENT
// ============================================================================
namespace State {
// Atomic flags for signal-safe communication
std::atomic<bool> timer_running{false};
std::atomic<int> seconds_remaining{0};
std::atomic<bool> restart_requested{false};
std::atomic<bool> break_requested{false}; // NEW: Manual break trigger
std::atomic<bool> shutdown_requested{false};
} // namespace State

// ============================================================================
// FILE I/O UTILITIES
// ============================================================================
namespace FileIO {

void write_state(bool running, int seconds) {
    std::ostringstream oss;

    if (running && seconds > 0) {
        const int minutes = seconds / 60;
        const int secs = seconds % 60;
        oss
            // << "running:"
            << std::setfill('0') << std::setw(2) << minutes << ":"
            << std::setfill('0') << std::setw(2) << secs;
    } else {
        oss << "break";
    }

    // Atomic write via temp file + rename
    const std::string state_file = Config::get_state_file();
    const std::string tmp_path = state_file + ".tmp";

    std::ofstream ofs(tmp_path, std::ios::trunc);
    if (ofs) {
        ofs << oss.str() << std::endl;
        ofs.close();
        std::rename(tmp_path.c_str(), state_file.c_str());
    }
}

void write_pid() {
    std::ofstream ofs(Config::get_pid_file(), std::ios::trunc);
    if (ofs) {
        ofs << getpid() << std::endl;
    }
}

pid_t read_pid() {
    std::ifstream ifs(Config::get_pid_file());
    pid_t pid = -1;
    if (ifs) {
        ifs >> pid;
    }
    return pid;
}

bool daemon_is_running() {
    pid_t pid = read_pid();
    if (pid <= 0)
        return false;
    return (kill(pid, 0) == 0);
}

void cleanup() {
    std::remove(Config::get_state_file().c_str());
    std::remove(Config::get_pid_file().c_str());
}
} // namespace FileIO

// ============================================================================
// SIGNAL HANDLERS
// ============================================================================
// These ONLY set atomic flags - actual work happens in main loop.
// No SA_RESTART flag = sleep can be interrupted immediately.

namespace Signals {

void handle_sigusr1(int /*signum*/) {
    // SIGUSR1: Start/restart timer
    State::restart_requested.store(true);
}

void handle_sigusr2(int /*signum*/) {
    // SIGUSR2: Manual break trigger
    State::break_requested.store(true);
}

void handle_sigterm(int /*signum*/) {
    // SIGTERM/SIGINT: Graceful shutdown
    State::shutdown_requested.store(true);
}

void setup_handlers() {
    struct sigaction sa_usr1{}, sa_usr2{}, sa_term{};

    // SIGUSR1 - Start/restart timer
    sa_usr1.sa_handler = handle_sigusr1;
    sigemptyset(&sa_usr1.sa_mask);
    sa_usr1.sa_flags = 0; // NO SA_RESTART - allows sleep interruption
    sigaction(SIGUSR1, &sa_usr1, nullptr);

    // SIGUSR2 - Manual break
    sa_usr2.sa_handler = handle_sigusr2;
    sigemptyset(&sa_usr2.sa_mask);
    sa_usr2.sa_flags = 0;
    sigaction(SIGUSR2, &sa_usr2, nullptr);

    // SIGTERM/SIGINT - Shutdown
    sa_term.sa_handler = handle_sigterm;
    sigemptyset(&sa_term.sa_mask);
    sa_term.sa_flags = 0;
    sigaction(SIGTERM, &sa_term, nullptr);
    sigaction(SIGINT, &sa_term, nullptr);
}
} // namespace Signals

// ============================================================================
// POPUP DISPLAY
// ============================================================================
namespace Popup {
std::string get_live_display() {
    // Read i3's environment to get the real DISPLAY
    FILE *fp = popen("cat /proc/$(pgrep -x i3 | head -1)/environ 2>/dev/null "
                     "| tr '\\0' '\\n' | grep '^DISPLAY=' | cut -d= -f2",
                     "r");
    if (!fp)
        return ":1"; // sensible fallback

    char buf[64] = {};
    if (fgets(buf, sizeof(buf), fp)) {
        pclose(fp);
        // Strip trailing newline
        std::string display(buf);
        if (!display.empty() && display.back() == '\n') {
            display.pop_back();
        }
        return display.empty() ? ":1" : display;
    }
    pclose(fp);
    return ":1"; // fallback
}

void show_completion_popup() {
    const std::string display = get_live_display();
    std::string cmd = "DISPLAY=" + display + " rofi -e '☕ Break Time! Step away. Stretch. Breathe.' -theme $HOME/.config/rofi/pomodoro.rasi";

    std::system(cmd.c_str());
}
// Separate function for second confirmation popup
void show_confirmation_popup() {
    const std::string display = get_live_display();
    std::string cmd = "DISPLAY=" + display + " rofi -e '☕ Break Time! Step away. Stretch. Breathe.' -theme $HOME/.config/rofi/pomodoro.rasi";

    std::system(cmd.c_str());
}

} // namespace Popup

// ============================================================================
// TIMER DAEMON - Core Logic
// ============================================================================
namespace Daemon {

// Interruptible sleep - polls flag every 100ms
// Returns true if sleep completed, false if interrupted by restart request
bool interruptible_sleep_1s() {
    for (int i = 0; i < Config::POLLS_PER_SECOND; ++i) {
        if (State::restart_requested.load() ||
            State::break_requested.load() ||
            State::shutdown_requested.load()) {
            return false; // Interrupted
        }
        std::this_thread::sleep_for(
            std::chrono::milliseconds(Config::POLL_INTERVAL_MS));
    }
    return true; // Completed full second
}

void run() {
    FileIO::write_pid();
    Signals::setup_handlers();

    // Initial state: break (not running)
    FileIO::write_state(false, 0);

    while (!State::shutdown_requested.load()) {

        // ============================================================
        // Priority 1: Check for restart signal (start/restart timer)
        // ============================================================
        if (State::restart_requested.exchange(false)) {
            State::seconds_remaining.store(Config::POMODORO_SECONDS);
            State::timer_running.store(true);
            // Clear any pending break request since we're starting fresh
            State::break_requested.store(false);
        }

        // ============================================================
        // Priority 2: Check for manual break request
        // ============================================================
        if (State::break_requested.exchange(false)) {
            // Stop timer if running
            State::timer_running.store(false);
            State::seconds_remaining.store(0);
            FileIO::write_state(false, 0);

            // show both popups( escape twice)
            Popup::show_completion_popup();
            // Popup::show_confirmation_popup();

            // Send notification and restart
            // std::system("notify-send -u normal '🍅 Pomodoro' 'Break time!'");

            // Show popup (blocking)
            // Popup::show_completion_popup();
            continue; // Back to top of loop
        }

        // ============================================================
        // Timer countdown logic
        // ============================================================
        if (State::timer_running.load()) {
            int remaining = State::seconds_remaining.load();

            if (remaining > 0) {
                FileIO::write_state(true, remaining);

                // Interruptible 1-second sleep
                if (interruptible_sleep_1s()) {
                    // Full second elapsed - decrement
                    State::seconds_remaining.fetch_sub(1);
                }
                // If interrupted, loop continues and checks flags

            } else {
                // Timer completed!
                State::timer_running.store(false);
                FileIO::write_state(false, 0);

                // Show blocking popup
                Popup::show_completion_popup();

                // Show blocking popup
                // Popup::show_confirmation_popup();

                // Send notification that timer is restarting
                std::system("notify-send -u normal '🍅 Pomodoro' 'Timer restarted!'");

                State::seconds_remaining.store(Config::POMODORO_SECONDS);
                State::timer_running.store(true);
            }
        } else {
            // In break state - wait for signal
            FileIO::write_state(false, 0);
            std::this_thread::sleep_for(
                std::chrono::milliseconds(Config::POLL_INTERVAL_MS));
        }
    }

    // Cleanup on shutdown
    FileIO::cleanup();
}

void daemonize() {
    pid_t pid = fork();

    if (pid < 0) {
        std::cerr << "[pomodoro] Fork failed!" << std::endl;
        std::exit(EXIT_FAILURE);
    }

    if (pid > 0) {
        // Parent exits
        std::cout << "[pomodoro] Daemon started. PID: " << pid << std::endl;
        std::exit(EXIT_SUCCESS);
    }

    // Child: create new session
    if (setsid() < 0) {
        std::exit(EXIT_FAILURE);
    }

    // Redirect stdio to /dev/null
    int fd = open("/dev/null", O_RDWR);
    if (fd >= 0) {
        dup2(fd, STDIN_FILENO);
        dup2(fd, STDOUT_FILENO);
        dup2(fd, STDERR_FILENO);
        if (fd > STDERR_FILENO)
            close(fd);
    }

    chdir("/tmp");
    run();
}
} // namespace Daemon

// ============================================================================
// CONTROL INTERFACE
// ============================================================================
namespace Control {

bool send_signal(int sig, const char *action_name) {
    pid_t pid = FileIO::read_pid();

    if (pid <= 0 || kill(pid, 0) != 0) {
        std::cerr << "[pomodoro] Daemon not running. Start with: pomodoro --daemon" << std::endl;
        return false;
    }

    if (kill(pid, sig) == 0) {
        std::cout << "[pomodoro] " << action_name << " signal sent." << std::endl;
        return true;
    } else {
        std::cerr << "[pomodoro] Failed to send signal: " << strerror(errno) << std::endl;
        return false;
    }
}

void start_timer() {
    send_signal(SIGUSR1, "Start/restart");
}

void trigger_break() {
    send_signal(SIGUSR2, "Break");
}

void stop_daemon() {
    send_signal(SIGTERM, "Shutdown");
}

void print_status() {
    std::ifstream ifs(Config::get_state_file());
    std::string line;
    if (ifs && std::getline(ifs, line)) {
        std::cout << line << std::endl;
    } else {
        std::cout << "break:" << std::endl;
    }
}

void print_usage(const char *prog) {
    std::cout << "Pomodoro Timer Daemon v2.0\n\n"
              << "Usage: " << prog << " [OPTION]\n\n"
              << "Options:\n"
              << "  --daemon    Start the pomodoro daemon (background)\n"
              << "  --start     Start/restart the 25-minute timer\n"
              << "  --break     Trigger break popup manually\n"
              << "  --status    Print current timer state\n"
              << "  --stop      Stop the daemon gracefully\n"
              << "  --help      Show this help\n\n"
              << "Signals:\n"
              << "  SIGUSR1     Start/restart timer\n"
              << "  SIGUSR2     Trigger break\n"
              << "  SIGTERM     Shutdown daemon\n";
}
} // namespace Control

// ============================================================================
// MAIN
// ============================================================================
int main(int argc, char *argv[]) {
    if (argc < 2) {
        Control::print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    const std::string arg = argv[1];

    if (arg == "--daemon") {
        if (FileIO::daemon_is_running()) {
            std::cerr << "[pomodoro] Daemon already running (PID: "
                      << FileIO::read_pid() << ")" << std::endl;
            return EXIT_FAILURE;
        }
        Daemon::daemonize();

    } else if (arg == "--start") {
        Control::start_timer();

    } else if (arg == "--break") {
        Control::trigger_break();

    } else if (arg == "--stop") {
        Control::stop_daemon();

    } else if (arg == "--status") {
        Control::print_status();

    } else if (arg == "--help" || arg == "-h") {
        Control::print_usage(argv[0]);

    } else {
        std::cerr << "Unknown option: " << arg << std::endl;
        Control::print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
