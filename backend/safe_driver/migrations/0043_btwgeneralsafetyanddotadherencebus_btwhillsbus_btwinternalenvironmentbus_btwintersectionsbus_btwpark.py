# Generated by Django 2.2.19 on 2021-05-08 23:26

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('safe_driver', '0042_auto_20210421_0711'),
    ]

    operations = [
        migrations.CreateModel(
            name='BTWTurningBus',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('signals_correctly', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Signals correctly')),
                ('gets_in_proper_time', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Gets in proper lane')),
                ('downshifts_to_pulling_gear', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Downshifts to pulling gear')),
                ('handles_light_correctly', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Handles light correctly')),
                ('setup_and_execution', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Set up and execution')),
                ('turn_speed', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Turn Speed')),
                ('mirror_follow_up', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Mirror follow up')),
                ('turns_lane_to_lane', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Turns lane to lane')),
                ('notes', models.TextField(blank=True, null=True, verbose_name='Notes')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('btw', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='btw_turning_bus', to='safe_driver.BTWBus')),
            ],
            options={
                'verbose_name': 'BTW - Turning Bus',
                'ordering': ('-created',),
            },
        ),
        migrations.CreateModel(
            name='BTWRailroadCrossingBus',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('signal_and_activate_4_ways', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Signal & Activate 4-ways')),
                ('stop_prior', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Stop 10’ to 50’ prior')),
                ('open_window_and_door', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Open window & door')),
                ('look_listen_clear', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Look, Listen & Clear')),
                ('signal_and_merge_into_traffic', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Signal & merge into traffic')),
                ('notes', models.TextField(blank=True, null=True, verbose_name='Notes')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('btw', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='btw_railroad_crossing_bus', to='safe_driver.BTWBus')),
            ],
            options={
                'verbose_name': 'BTW - Railroad Crossing Bus',
                'ordering': ('-created',),
            },
        ),
        migrations.CreateModel(
            name='BTWPassingBus',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('sufficient_space_to_pass', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Sufficient Space to Pass')),
                ('signals_property', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Signals Property')),
                ('check_mirrors', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Checks Mirrors')),
                ('notes', models.TextField(blank=True, null=True, verbose_name='Notes')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('btw', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='btw_passing_bus', to='safe_driver.BTWBus')),
            ],
            options={
                'verbose_name': 'BTW - Passing Bus',
                'ordering': ('-created',),
            },
        ),
        migrations.CreateModel(
            name='BTWParkingBus',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('does_not_hit_curb', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Doesn’t hit curb')),
                ('curbs_wheels', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Curbs wheels')),
                ('chock_wheels', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Chock wheels (if required)')),
                ('park_brake_applied', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Park Brake applied')),
                ('trans_in_neutral', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Trans in neutral')),
                ('engine_off', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Engine off - Take keys')),
                ('notes', models.TextField(blank=True, null=True, verbose_name='Notes')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('btw', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='btw_parking_bus', to='safe_driver.BTWBus')),
            ],
            options={
                'verbose_name': 'BTW - Parking Bus',
                'ordering': ('-created',),
            },
        ),
        migrations.CreateModel(
            name='BTWIntersectionsBus',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('approach_decision_point', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Approach -decision point')),
                ('clear_intersection', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Clear Intersection L-R-L')),
                ('check_mirrors', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Check Mirrors')),
                ('full_stop', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Full stop when needed')),
                ('times_light_or_starts', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Times light or starts too fast')),
                ('steering_axel_staright', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Steering axel straight')),
                ('yields_right_of_way', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Yields right-of-way')),
                ('proper_speed_or_gear', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Proper speed/gear')),
                ('leaves_space', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Leaves space for an out')),
                ('stop_lines', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Stop Lines - crosswalks')),
                ('railroad_crossings', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Railroad crossings')),
                ('notes', models.TextField(blank=True, null=True, verbose_name='Notes')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('btw', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='btw_intersections_bus', to='safe_driver.BTWBus')),
            ],
            options={
                'verbose_name': 'BTW - Intersections BUS',
                'ordering': ('-created',),
            },
        ),
        migrations.CreateModel(
            name='BTWInternalEnvironmentBus',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('driver_aid', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Driver Aid')),
                ('interior_passenger_mirror_check', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Interior Passenger Mirror Check')),
                ('safe_path', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Safe Path')),
                ('maintain_proper_grip', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Maintain Proper Grip')),
                ('smooth_driving_movements', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Smooth Driving Movements')),
                ('maintain_comfortable_environment', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Maintain a Comfortable Environment')),
                ('notes', models.TextField(blank=True, null=True, verbose_name='Notes')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('btw', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='btw_internal_environtment_bus', to='safe_driver.BTWBus')),
            ],
            options={
                'verbose_name': 'BTW - Internal Environtment - Bus',
                'ordering': ('-created',),
            },
        ),
        migrations.CreateModel(
            name='BTWHillsBus',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('proper_gear_up_down', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Proper gear up or down')),
                ('avoids_rolling_back', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Avoids rolling back H/V')),
                ('test_brakes_prior', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Test brakes prior')),
                ('notes', models.TextField(blank=True, null=True, verbose_name='Notes')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('btw', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='btw_hills_bus', to='safe_driver.BTWBus')),
            ],
            options={
                'verbose_name': 'BTW - Hills Bus',
                'ordering': ('-created',),
            },
        ),
        migrations.CreateModel(
            name='BTWGeneralSafetyAndDOTAdherenceBus',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('avoids_crowding_effect', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Avoids crowding effect')),
                ('stays_right_or_correct_lane', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Stays to the right/correct lane')),
                ('aware_hours_of_service', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Aware of hours of service')),
                ('proper_use_off_mirrors', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Proper use of mirrors')),
                ('self_confident_not_complacement', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Self confident not complacent')),
                ('check_instruments', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Checks instruments')),
                ('uses_horn_properly', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Uses horn properly')),
                ('maintains_dot_log', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Maintains DOT log')),
                ('drives_defensively', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Drives defensively')),
                ('company_haz_mat_protocol', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Company Haz Mat protocol')),
                ('air_cans_or_line_moisture_free', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Air cans/lines free of moisture')),
                ('avoid_distractions_while_driving', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Avoid distractions while driving')),
                ('works_safely_to_avoid_injuries', models.IntegerField(choices=[(1, '1'), (2, '2'), (3, '3'), (4, '4'), (5, '5'), (0, 'N/A')], default=0, verbose_name='Works safely to avoid injuries')),
                ('notes', models.TextField(blank=True, null=True, verbose_name='Notes')),
                ('created', models.DateTimeField(auto_now_add=True)),
                ('updated', models.DateTimeField(auto_now=True)),
                ('btw', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, related_name='btw_general_safety_bus', to='safe_driver.BTWBus')),
            ],
            options={
                'verbose_name': 'BTW - General Safety and DOT adherence - Bus',
                'ordering': ('-created',),
            },
        ),
    ]
