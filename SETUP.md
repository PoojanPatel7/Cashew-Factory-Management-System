# CashewPro ERP — Production Setup Guide

This guide provides instructions to deploy the Cashew Factory Management System in a production environment using Docker Compose.

## 1. Server Requirements
*   **OS:** Ubuntu 22.04 LTS (or similar Linux distro)
*   **CPU:** 2 vCPU minimum
*   **RAM:** 4GB minimum (8GB recommended for larger databases)
*   **Storage:** 40GB SSD

## 2. Prerequisites
Install Docker and Docker Compose on your server:
```bash
sudo apt update
sudo apt install docker.io docker-compose -y
```

## 3. Deployment Steps

### Clone the Repository
```bash
git clone https://github.com/PoojanPatel7/Cashew-Factory-Management-System.git
cd Cashew-Factory-Management-System
```

### Configure Environment Variables
Create a `.env` file in the root directory:
```env
PORT=80
DB_HOST=postgres
DB_USER=cashew_admin
DB_PASSWORD=SecurePassword123!
DB_NAME=cashewpro_db
JWT_SECRET=YourSuperSecretKeyGoesHere
ENCRYPT_MASTER_KEY=GenerateA32ByteKeyHere
```

### SSL Configuration (Nginx)
Ensure you have a domain pointing to your server IP. Edit the `nginx/conf.d/default.conf` to include your domain and SSL certificates (via Let's Encrypt).

### Run the Application
```bash
sudo docker-compose up -d --build
```

## 4. Initial Configuration
1. Open your browser and navigate to your domain.
2. The system will prompt you for an initial `Admin` user creation.
3. Access the `/settings` route to configure Factory details, Grades, and initial Tax (GST) settings.

## 5. Automated Backups
To schedule automated encrypted backups, add the following cron job (`crontab -e`):
```bash
0 2 * * * docker exec cashewpro_db pg_dump -U cashew_admin cashewpro_db | gzip > /backups/db_backup_$(date +\%F).sql.gz
```
