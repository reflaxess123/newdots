# Newdots (Chezmoi)

Dotfiles под управлением [chezmoi](https://www.chezmoi.io/).

## Структура chezmoi

Файлы хранятся с префиксами:
- `dot_` → `.` (например `dot_zshrc` → `.zshrc`)
- `private_` → файл с ограниченными правами
- `executable_` → исполняемый файл

## Управляемые конфиги

### Shell
- `.zshrc` — Zsh конфиг
- `.p10k.zsh` — Powerlevel10k тема
- `.tmux.conf.local` — Oh My Tmux
- `.gitconfig` — Git настройки

### Композиторы
- `.config/hypr/` — Hyprland
- `.config/niri/` — Niri

### Терминалы
- `.config/ghostty/` — основной
- `.config/kitty/`
- `.config/alacritty/`

### Редактор
- `.config/nvim/` — NvChad

### Бары и лаунчеры
- `.config/waybar/`
- `.config/rofi/`
- `.config/wofi/`

### Темы
- `.config/gtk-3.0/`
- `.config/gtk-4.0/`
- `.config/qt5ct/`
- `.config/qt6ct/`

### Другое
- `.config/sing-box/` — VPN
- `.config/swaync/` — уведомления
- `.config/neofetch/`

## Команды chezmoi

### Добавить файл
```bash
chezmoi add ~/.config/путь/к/файлу
```

### Добавить несколько файлов
```bash
chezmoi add ~/.zshrc ~/.config/hypr/hyprland.conf
```

### Проверить различия
```bash
chezmoi diff
```

### Посмотреть статус
```bash
chezmoi status
```

### Применить изменения из репы на систему
```bash
chezmoi apply
```

### Обновить файл в репе (если изменил локально)
```bash
chezmoi re-add ~/.config/файл
```

### Удалить файл из управления
```bash
chezmoi forget ~/.config/файл
```

## Как обновить репу

```bash
# 1. Добавить изменённые файлы
chezmoi add ~/.config/изменённый/файл

# 2. Закоммитить
cd ~/.local/share/chezmoi
git add -A
git commit -m "Описание изменений"
git push
```

## Быстрое обновление всего

```bash
# Добавить все ключевые конфиги
chezmoi add \
  ~/.zshrc \
  ~/.tmux.conf.local \
  ~/.config/hypr/hyprland.conf \
  ~/.config/niri/config.kdl \
  ~/.config/nvim/lua/configs/lspconfig.lua \
  ~/.config/nvim/lua/mappings.lua

# Закоммитить
cd ~/.local/share/chezmoi && git add -A && git commit -m "Update configs" && git push
```

## Важно

- Chezmoi хранит файлы в `~/.local/share/chezmoi/`
- При конфликте прав (mode) — это нормально, не влияет на работу
- Есть также репа `hyperland-dots` — обновляй обе при изменениях
