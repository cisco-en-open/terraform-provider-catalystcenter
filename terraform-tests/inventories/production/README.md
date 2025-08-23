# Production Environment

This directory contains the configuration for the **production** environment of the Terraform Provider Catalyst Center Test Suite.

## ⚠️ PRODUCTION ENVIRONMENT WARNING ⚠️

**This is a PRODUCTION environment configuration. Use with extreme caution.**

- All operations affect production Catalyst Center instances
- Changes can impact live network infrastructure
- Always follow change management procedures
- Ensure proper approvals before execution
- Test thoroughly in dev/staging first

## Overview

The production environment is designed for:
- **VALIDATION ONLY** - Do not create unnecessary resources
- Critical bug reproduction in production-like environment
- Final validation of provider updates before release
- Production incident troubleshooting (when necessary)

## Configuration

### Files

- **`terraform.tfvars.example`** - Example configuration file
- **`terraform.tfvars`** - Actual configuration (create from example) - **NEVER COMMIT**
- **`inventory.tf`** - Terraform provider and environment configuration
- **`variables.tf`** - Variable definitions
- **`README.md`** - This documentation

### Setup

1. **Create Configuration File** ⚠️
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit Configuration** ⚠️
   Update `terraform.tfvars` with your production Catalyst Center details:
   ```hcl
   catalyst_username = "admin"
   catalyst_password = "your-production-password"  # Use secure credential management
   catalyst_base_url = "https://production-catalyst-center.example.com"
   ```

3. **Initialize Environment** ⚠️
   ```bash
   ../../scripts/setup-inventory.sh production
   ```

## Environment Characteristics

### Security Settings (STRICT)
- **Debug Mode**: DISABLED (`catalyst_debug = false`)
- **SSL Verification**: REQUIRED (`catalyst_ssl_verify = true`)
- **Validation**: ENABLED for safety (`enable_validation = true`)
- **Change Management**: Required for all operations

### Resource Limits (PRODUCTION SCALE)
Production-scale limits (use with caution):
- **Areas**: Maximum 100
- **Buildings**: Maximum 500
- **Floors**: Maximum 2000
- **Devices**: Maximum 5000

### Production Features
- **Auto Cleanup**: DISABLED (`auto_cleanup = false`) - Manual cleanup required
- **Backup Configs**: ENABLED (`backup_configs = true`) - All changes backed up
- **Retry Attempts**: Conservative 3 attempts
- **Test Timeout**: Extended 120 minutes for complex operations
- **Parallel Tests**: DISABLED (`parallel_tests = 1`) - Sequential execution only

### Resource Naming
All resources use the `prod` prefix for identification:
- Areas: `prod-area-*`
- Buildings: `prod-bldg-*`
- Floors: `prod-floor-*`
- Devices: `prod-device-*`

## Security and Compliance

### Production Security Requirements
- SSL verification is MANDATORY
- Debug logging is DISABLED
- All operations are logged and audited
- Credential management via secure vaults
- Network access restrictions apply

### Change Management
- **All operations require approval**
- **Maintenance windows: 02:00-04:00 UTC**
- **Change documentation required**
- **Rollback procedures must be defined**
- **Impact assessment required**

### Compliance
- All operations are audited
- Change tracking is enabled
- Configuration backups are mandatory
- Security scans are performed
- Access is logged and monitored

## Usage (WITH EXTREME CAUTION)

### Prerequisites Checklist
- [ ] Change management approval obtained
- [ ] Backup procedures verified
- [ ] Rollback plan documented
- [ ] Impact assessment completed
- [ ] Maintenance window scheduled
- [ ] Team notifications sent

### Validate Configuration Only
```bash
../../scripts/validate-config.sh production
```

### Emergency Troubleshooting Only
```bash
# ONLY for critical production issues
../../scripts/run-test.sh production site-hierarchy --dry-run
```

### Manual Resource Management
```bash
# NEVER run without approval
../../scripts/cleanup.sh production --dry-run
```

## Production Procedures

### Emergency Response
1. **Assess Impact**: Determine scope of issue
2. **Get Approval**: Obtain emergency change approval
3. **Create Backup**: Backup current configurations
4. **Execute Minimally**: Make minimal necessary changes
5. **Validate**: Verify fixes work correctly
6. **Document**: Document all changes made
7. **Review**: Post-incident review required

### Maintenance Procedures
1. **Schedule Window**: Use defined maintenance window
2. **Notify Stakeholders**: Send advance notifications
3. **Backup Everything**: Complete configuration backup
4. **Test in Staging**: Verify all procedures in staging first
5. **Execute Carefully**: Follow approved procedures exactly
6. **Validate Results**: Confirm all operations successful
7. **Update Documentation**: Record all changes

## Monitoring and Alerting

### Built-in Monitoring
- All operations are logged
- Resource usage is monitored
- Performance metrics are tracked
- Error rates are measured

### Alerting
- Configuration changes trigger alerts
- Resource limit violations alert
- Error conditions trigger notifications
- Performance degradation alerts

### Audit Trail
- Complete operation logging
- Change attribution tracking
- Time-stamped audit records
- Compliance reporting

## Risk Management

### Risk Mitigation
- Mandatory validation before execution
- Sequential operation execution (no parallel)
- Extended timeout for careful execution
- Comprehensive backup procedures
- Rollback capabilities tested

### Risk Assessment
- **HIGH RISK**: Any resource creation
- **MEDIUM RISK**: Configuration validation
- **LOW RISK**: Read-only operations
- **CRITICAL RISK**: Bulk operations

## Troubleshooting (Production)

### Critical Issues Only

1. **Connection Failures**
   - Check network connectivity
   - Verify SSL certificates
   - Confirm credential validity
   - Review firewall rules

2. **Resource Conflicts**
   - Identify conflicting resources
   - Plan resolution carefully
   - Execute with approval only
   - Document resolution steps

3. **Performance Issues**
   - Monitor system resources
   - Check API rate limits
   - Review concurrent operations
   - Analyze network latency

### Debug Procedures (Emergency Only)
```bash
# ONLY for critical production debugging
# Requires emergency approval
echo 'catalyst_debug = true' >> terraform.tfvars
```

## Backup and Recovery

### Backup Procedures
- Automatic configuration backup before changes
- Manual backup verification required
- 30-day retention period
- Off-site backup storage

### Recovery Procedures
- Document all recovery steps
- Test recovery procedures regularly
- Maintain recovery time objectives
- Ensure data consistency

## Compliance and Auditing

### Regulatory Requirements
- All changes must be documented
- Access must be logged and monitored
- Configurations must be backed up
- Security controls must be validated

### Audit Requirements
- Monthly audit reviews
- Change management compliance
- Security posture validation
- Performance benchmark reviews

## IMPORTANT REMINDERS

### Before ANY Production Operation:
1. ✅ **Approval obtained** from change management
2. ✅ **Tested in staging** environment first
3. ✅ **Backup created** and verified
4. ✅ **Rollback plan** documented and tested
5. ✅ **Team notified** of planned changes
6. ✅ **Maintenance window** scheduled if needed

### During Production Operations:
- Proceed slowly and carefully
- Monitor all operations closely
- Be prepared to rollback immediately
- Document everything in real-time

### After Production Operations:
- Validate all changes worked correctly
- Confirm no unintended side effects
- Update documentation
- Conduct post-change review

## Support and Escalation

For production issues:
1. **Level 1**: Configuration validation issues
2. **Level 2**: Provider functionality issues  
3. **Level 3**: Critical production incidents
4. **Emergency**: Infrastructure impact

**Remember: Production environment should be used ONLY when absolutely necessary. Always prefer dev/staging for testing and validation.**