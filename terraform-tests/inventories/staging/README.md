# Staging Environment

This directory contains the configuration for the **staging** environment of the Terraform Provider Catalyst Center Test Suite.

## Overview

The staging environment is designed for:
- Pre-production testing and validation
- Integration testing with production-like configurations
- Performance and scale testing
- Final validation before production deployment

## Configuration

### Files

- **`terraform.tfvars.example`** - Example configuration file
- **`terraform.tfvars`** - Actual configuration (create from example)
- **`inventory.tf`** - Terraform provider and environment configuration
- **`variables.tf`** - Variable definitions
- **`README.md`** - This documentation

### Setup

1. **Create Configuration File**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit Configuration**
   Update `terraform.tfvars` with your staging Catalyst Center details:
   ```hcl
   catalyst_username = "admin"
   catalyst_password = "your-staging-password"
   catalyst_base_url = "https://staging-catalyst-center.example.com"
   ```

3. **Initialize Environment**
   ```bash
   ../../scripts/setup-inventory.sh staging
   ```

## Environment Characteristics

### Security Settings
- **Debug Mode**: Disabled for production-like behavior (`catalyst_debug = false`)
- **SSL Verification**: Enabled for security validation (`catalyst_ssl_verify = true`)
- **Validation**: Enabled for comprehensive testing (`enable_validation = true`)

### Resource Limits
Higher limits for staging to match production scenarios:
- **Areas**: Maximum 50
- **Buildings**: Maximum 100
- **Floors**: Maximum 200
- **Devices**: Maximum 500

### Testing Features
- **Auto Cleanup**: Disabled to preserve test results (`auto_cleanup = false`)
- **Backup Configs**: Enabled for configuration preservation (`backup_configs = true`)
- **Retry Attempts**: 5 attempts for robust testing
- **Test Timeout**: 60 minutes per test for complex scenarios
- **Parallel Tests**: Maximum 4 concurrent tests

### Resource Naming
All resources use the `stg` prefix:
- Areas: `stg-area-*`
- Buildings: `stg-bldg-*`
- Floors: `stg-floor-*`
- Devices: `stg-device-*`

## Security

### Staging Security Settings
- SSL verification is enabled
- Debug logging is disabled
- Production-like security posture
- Credential management follows production practices

### Best Practices
- Use staging-specific credentials separate from production
- Enable SSL verification and certificate validation
- Monitor and audit all staging activities
- Regular credential rotation
- Secure backup and configuration management

## Usage

### Run All Tests
```bash
../../scripts/run-test.sh staging
```

### Run Specific Use Case
```bash
../../scripts/run-test.sh staging site-hierarchy
```

### Run Integration Tests
```bash
../../scripts/run-test.sh staging --integration
```

### Validate Configuration
```bash
../../scripts/validate-config.sh staging
```

### Performance Testing
```bash
../../scripts/run-test.sh staging --performance
```

### Cleanup Resources
```bash
../../scripts/cleanup.sh staging
```

## Testing Types

### Integration Testing
- End-to-end workflow validation
- Cross-use-case compatibility
- State management validation
- Error handling and recovery

### Performance Testing
- Resource creation/deletion timing
- Concurrent operation testing
- Scale testing with maximum resource limits
- Memory and resource utilization

### Security Testing
- SSL/TLS validation
- Credential handling verification
- Access control testing
- Audit trail validation

## Monitoring and Validation

### Built-in Validation
- Connectivity testing before execution
- Resource limit validation
- Configuration syntax verification
- State consistency checks

### Performance Metrics
- Execution time tracking
- Resource utilization monitoring
- Success/failure rate analysis
- Throughput measurements

### Backup and Recovery
- Automatic configuration backups
- State file preservation
- Recovery procedures documentation
- Rollback capability testing

## Troubleshooting

### Common Issues

1. **SSL Certificate Errors**
   - Verify staging Catalyst Center SSL certificates
   - Check certificate chain and validity
   - Ensure proper CA trust configuration

2. **Resource Limit Exceeded**
   - Monitor current resource counts
   - Clean up unused resources
   - Review and adjust limits if necessary

3. **Performance Issues**
   - Check network connectivity and latency
   - Monitor Catalyst Center resource utilization
   - Review concurrent operation limits

4. **Integration Failures**
   - Validate cross-use-case dependencies
   - Check state file consistency
   - Verify resource naming conflicts

### Debug Procedures
Although debug mode is disabled by default, it can be temporarily enabled:
```bash
# Enable debug mode for troubleshooting
echo 'catalyst_debug = true' >> terraform.tfvars
```

### Validation Checks
Staging environment includes comprehensive validation:
- Pre-execution connectivity tests
- Mid-execution state validation
- Post-execution verification
- Cleanup validation

## Workflow

### Standard Staging Workflow
1. **Setup**: Initialize staging environment
2. **Validate**: Run configuration and connectivity validation
3. **Test**: Execute complete test suite
4. **Integration**: Run cross-use-case integration tests
5. **Performance**: Execute performance and scale tests
6. **Review**: Analyze results and metrics
7. **Cleanup**: Clean up resources (manual in staging)

### Pre-Production Validation
1. **Security**: Validate SSL and security configurations
2. **Scale**: Test with production-like resource volumes
3. **Performance**: Benchmark operation timings
4. **Reliability**: Test error handling and recovery
5. **Documentation**: Verify procedures and runbooks

## Metrics and Reporting

### Success Metrics
- Test pass/fail rates
- Execution time benchmarks
- Resource utilization efficiency
- Error recovery success rates

### Performance Baselines
- Resource creation times
- API response times
- Concurrent operation limits
- Memory and CPU utilization

## Next Steps

After successful staging validation:
1. Review staging test results and metrics
2. Document any issues or limitations found
3. Update production procedures based on staging learnings
4. Prepare production deployment with validated configurations