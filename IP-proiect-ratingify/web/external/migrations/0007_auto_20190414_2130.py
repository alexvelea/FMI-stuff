# Generated by Django 2.1.7 on 2019-04-14 21:30

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('external', '0006_task_date_added'),
    ]

    operations = [
        migrations.AddField(
            model_name='contest',
            name='_extra',
            field=models.TextField(default='{}'),
        ),
        migrations.AddField(
            model_name='contestuser',
            name='_extra',
            field=models.TextField(default='{}'),
        ),
        migrations.AddField(
            model_name='task',
            name='_extra',
            field=models.TextField(default='{}'),
        ),
        migrations.AddField(
            model_name='user',
            name='_extra',
            field=models.TextField(default='{}'),
        ),
        migrations.AddField(
            model_name='usertask',
            name='_extra',
            field=models.TextField(default='{}'),
        ),
    ]
