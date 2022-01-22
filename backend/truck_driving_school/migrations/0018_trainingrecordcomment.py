# Generated by Django 2.2.24 on 2021-11-22 14:54

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('truck_driving_school', '0017_auto_20211112_1421'),
    ]

    operations = [
        migrations.CreateModel(
            name='TrainingRecordComment',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('body', models.TextField(verbose_name='Body')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('training_record', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='comment', to='truck_driving_school.DriverTrainigRecord')),
            ],
            options={
                'verbose_name': 'Training Record Comment',
                'verbose_name_plural': 'Training Record Comments',
                'ordering': ('training_record__day', 'training_record__title'),
            },
        ),
    ]