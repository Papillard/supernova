# ProfConnect

ProfConnect met en relation des parents avec des professeurs de l'Éducation nationale. Différenciant majeur : uniquement des vrais enseignants, pas d'étudiants.

## 🚀 Lancer l'application en local

### Prérequis

- Ruby (version spécifiée dans `.ruby-version` ou `Gemfile`)
- PostgreSQL
- Node.js (pour Tailwind CSS)

### Installation

1. **Cloner le repository**
   ```bash
   git clone <repository-url>
   cd supernova
   ```

2. **Installer les dépendances**
   ```bash
   bundle install
   npm install
   ```

3. **Configurer la base de données**
   ```bash
   # S'assurer que PostgreSQL est démarré
   # Sur macOS avec Homebrew:
   brew services start postgresql@15
   # ou démarrer manuellement:
   /opt/homebrew/opt/postgresql@15/bin/pg_ctl -D /opt/homebrew/var/postgresql@15 start

   # Créer la base de données
   bin/rails db:create
   bin/rails db:migrate
   ```

4. **Lancer le serveur de développement**
   ```bash
   bin/dev
   ```

   Cette commande lance :
   - Le serveur Rails sur `http://localhost:3000`
   - Le watcher Tailwind CSS pour recompiler les styles

## 👥 Authentification

### Créer un compte

#### Compte Parent

1. Visitez `/parents/sign_up`
2. Remplissez le formulaire avec :
   - Email
   - Mot de passe (minimum 6 caractères)
   - Confirmation du mot de passe
3. Après l'inscription, vous serez automatiquement connecté et redirigé vers `/teachers`

#### Compte Professeur

1. Visitez `/teachers/sign_up`
2. Remplissez le formulaire avec :
   - Email professionnel (de préférence un email académique)
   - Mot de passe (minimum 6 caractères)
   - Confirmation du mot de passe
3. Après l'inscription, vous serez automatiquement connecté et redirigé vers `/dashboard/teacher`

### Se connecter

1. Visitez `/users/sign_in`
2. Entrez votre email et mot de passe
3. Vous serez redirigé selon votre rôle :
   - **Parent** → `/teachers`
   - **Professeur** → `/dashboard/teacher`

### Mot de passe oublié

1. Visitez `/users/password/new`
2. Entrez votre email
3. Vous recevrez un email avec un lien de réinitialisation
4. Cliquez sur le lien et suivez les instructions pour définir un nouveau mot de passe

### Se déconnecter

Une fois connecté, cliquez sur votre nom/email dans la barre de navigation, puis sur "Déconnexion".

## 📍 URLs clés

### Authentification

- **Signup parent** : `/parents/sign_up`
- **Signup professeur** : `/teachers/sign_up`
- **Login** : `/users/sign_in`
- **Mot de passe oublié** : `/users/password/new`

### Pages authentifiées

- **Listing des professeurs** (placeholder) : `/teachers`
- **Dashboard professeur** (placeholder) : `/dashboard/teacher`

## 🔧 Logique de redirection selon le rôle

Les redirections après login/signup sont gérées dans :

- **SessionsController** (`app/controllers/sessions_controller.rb`) : méthode `after_sign_in_path_for`
- **Parents::RegistrationsController** (`app/controllers/parents/registrations_controller.rb`) : méthode `after_sign_up_path_for`
- **Teachers::RegistrationsController** (`app/controllers/teachers/registrations_controller.rb`) : méthode `after_sign_up_path_for`

### Règles de redirection

- **Parent** → `/teachers`
- **Teacher** → `/dashboard/teacher`

## 📄 Pages placeholder

### `/teachers`

Page placeholder pour le listing des professeurs. Le contenu réel sera implémenté dans un prochain sprint.

**Contrôleur** : `TeachersController#index`
**Vue** : `app/views/teachers/index.html.erb`

### `/dashboard/teacher`

Page placeholder pour l'espace professeur. Le contenu réel (onboarding, validation) sera implémenté dans un prochain sprint.

**Contrôleur** : `Dashboard::TeachersController#show`
**Vue** : `app/views/dashboard/teachers/show.html.erb`

## 🧪 Tests

### Lancer les tests

```bash
bin/rails test
```

### Tests système d'authentification

Les tests système vérifient :

- ✅ Un parent peut s'inscrire via `/parents/sign_up` et est créé avec `role = "parent"`
- ✅ Un parent est redirigé vers `/teachers` après signup/login
- ✅ Un teacher peut s'inscrire via `/teachers/sign_up` et est créé avec `role = "teacher"`
- ✅ Un teacher est redirigé vers `/dashboard/teacher` après signup/login
- ✅ Un utilisateur peut se connecter via `/users/sign_in` et être redirigé selon son rôle
- ✅ Un utilisateur peut se déconnecter via le bouton logout
- ✅ Le flow "mot de passe oublié" fonctionne (email de reset déclenché)

**Fichier de test** : `test/system/authentication_test.rb`

## 🏗️ Architecture

### Modèle User

Le modèle `User` utilise Devise avec les modules suivants :
- `database_authenticatable` : authentification par email/mot de passe
- `registerable` : inscription
- `recoverable` : réinitialisation de mot de passe
- `rememberable` : "Se souvenir de moi"
- `validatable` : validations d'email et mot de passe

**Rôles** : Le modèle utilise un `enum` pour les rôles :
- `parent` (par défaut)
- `teacher`

### Contrôleurs personnalisés

- `SessionsController` : gère la connexion et les redirections
- `Parents::RegistrationsController` : gère l'inscription des parents
- `Teachers::RegistrationsController` : gère l'inscription des professeurs

### Layouts

- `application.html.erb` : layout par défaut (pages publiques)
- `authenticated.html.erb` : layout pour les pages authentifiées (avec navbar)

## 📝 Notes pour les développeurs

### Ajouter de nouvelles fonctionnalités

- Les pages `/teachers` et `/dashboard/teacher` sont des placeholders
- Ne pas créer de modèles `Teacher`, `Request`, ou `Message` dans ce sprint
- La logique de validation/onboarding des professeurs sera implémentée dans un prochain sprint

### Configuration Devise

La configuration Devise se trouve dans `config/initializers/devise.rb`.

### Styles

L'application utilise Tailwind CSS + DaisyUI pour le styling. Les composants DaisyUI sont utilisés pour :
- Les formulaires (`form-control`, `input`, `label`)
- Les boutons (`btn`, `btn-primary`)
- Les cartes (`card`, `card-body`)
- Les alertes (`alert`, `alert-error`)
- La navigation (`navbar`, `dropdown`)

## 🐛 Dépannage

### PostgreSQL ne démarre pas

Si vous rencontrez des erreurs de connexion à PostgreSQL :

1. Vérifier que PostgreSQL est démarré :
   ```bash
   ps aux | grep postgres
   ```

2. Démarrer PostgreSQL :
   ```bash
   brew services start postgresql@15
   # ou
   /opt/homebrew/opt/postgresql@15/bin/pg_ctl -D /opt/homebrew/var/postgresql@15 start
   ```

3. Vérifier la connexion :
   ```bash
   /opt/homebrew/opt/postgresql@15/bin/psql -l
   ```

### Erreurs de compilation Tailwind

Si les styles ne se compilent pas :

1. Vérifier que le watcher Tailwind est lancé (via `bin/dev`)
2. Redémarrer le watcher si nécessaire

## 📚 Ressources

- [Documentation Devise](https://github.com/heartcombo/devise)
- [Documentation Tailwind CSS](https://tailwindcss.com/docs)
- [Documentation DaisyUI](https://daisyui.com/)
